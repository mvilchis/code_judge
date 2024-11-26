#!/usr/bin/env python
################################################################################
# The Sandbox Libraries (Python) - Sample Script                               #
#                                                                              #
# Copyright (C) 2009-2013 LIU Yu, <pineapple.liu@gmail.com>                    #
# All rights reserved.                                                         #
#                                                                              #
# Redistribution and use in source and binary forms, with or without           #
# modification, are permitted provided that the following conditions are met:  #
#                                                                              #
# 1. Redistributions of source code must retain the above copyright notice,    #
#    this list of conditions and the following disclaimer.                     #
#                                                                              #
# 2. Redistributions in binary form must reproduce the above copyright notice, #
#    this list of conditions and the following disclaimer in the documentation #
#    and/or other materials provided with the distribution.                    #
#                                                                              #
# 3. Neither the name of the author(s) nor the names of its contributors may   #
#    be used to endorse or promote products derived from this software without #
#    specific prior written permission.                                        #
#                                                                              #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   #
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE     #
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR          #
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF         #
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS     #
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN      #
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)      #
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE   #
# POSSIBILITY OF SUCH DAMAGE.                                                  #
################################################################################

import os
import sys

try:
    # check platform type
    system, machine = os.uname()[0], os.uname()[4]
    if system not in ('Linux', ) or machine not in ('i686', 'x86_64', ):
        raise AssertionError("Unsupported platform type.\n")
    # check package availability / version
    import sandbox
    if not hasattr(sandbox, '__version__') or sandbox.__version__ < "0.3.4-3":
        raise AssertionError("Unsupported sandbox version.\n")
    from sandbox import *
except ImportError:
    sys.stderr.write("Required package(s) missing.\n")
    sys.exit(os.EX_UNAVAILABLE)
except AssertionError as e:
    sys.stderr.write(str(e))
    sys.exit(os.EX_UNAVAILABLE)


def main(args):
    # sandbox configuration
    cookbook = {
        'args': args[1],               # targeted program
        'stdin': sys.stdin,             # input to targeted program
        'stdout': sys.stdout,           # output from targeted program
        'stderr': sys.stdout,           # error from targeted program   //sys.stderr
        'quota': dict(wallclock=int(args[2])*1000,  # 30000 30 sec      //Se espera en segundos
                      cpu=int(args[3])*1000,         #2000 2 sec			//Se espera en segundos
                      memory=int(args[4])*1024,   #8388608 8 MB			//Se espera en kilobytes
                      disk=int(args[5])*1024)}    #1048576 1 MB			//Se espera en kilobytes
    # create a sandbox instance and execute till end
    msb = MiniSandbox(**cookbook)
    msb.run()
    # verbose statistics
    sys.stderr.write("result: %(result)s\ncpu: %(cpu)dms\nmem: %(mem)dkB\n" %
        msb.probe())
    return os.EX_OK


# mini sandbox with embedded policy
class MiniSandbox(SandboxPolicy, Sandbox):
    sc_table = None
    # white list of essential linux syscalls for statically-linked C programs
    sc_safe = dict(i686=set([0, 3, 4, 19, 45, 54, 90, 91, 122, 125, 140,163, 192, 197, 224, 243, 252, ]), 
 						x86_64 = set([0,1,5,9,12,21,63,89,158,231]), ) #//[8, 10, 11, 16, 25, 219
    # result code translation table
    #S_RESULT_PD        =  0,    /*!< Pending */
    #S_RESULT_OK        =  1,    /*!< Okay */
    #S_RESULT_RF        =  2,    /*!< Restricted Function */
    #S_RESULT_ML        =  3,    /*!< Memory Limit Exceed */
    #S_RESULT_OL        =  4,    /*!< Output Limit Exceed */
    #S_RESULT_TL        =  5,    /*!< Time Limit Exceed */
    #S_RESULT_RT        =  6,    /*!< Run Time Error (SIGSEGV, SIGFPE, ...) */
    #S_RESULT_AT        =  7,    /*!< Abnormal Termination */
    #S_RESULT_IE        =  8,    /*!< Internal Error (of sandbox executor) */
    #S_RESULT_BP        =  9,    /*!< Bad Policy (since 0.3.3) */    # result code translation table
    result_name = dict((getattr(Sandbox, 'S_RESULT_%s' % r), r) for r in
        ('PD', 'OK', 'RF', 'RT', 'TL', 'ML', 'OL', 'AT', 'IE', 'BP'))

    def __init__(self, *args, **kwds):
        # initialize table of system call rules
        self.sc_table = dict()
        if machine == 'x86_64':
            for (mode, abi) in ((0, 'x86_64'), (1, 'i686'), ):
                for scno in MiniSandbox.sc_safe[abi]:
                    self.sc_table[(scno, mode)] = self._CONT
        else:  # i686
            for scno in MiniSandbox.sc_safe[machine]:
                self.sc_table[scno] = self._CONT
        # initialize as a polymorphic sandbox-and-policy object
        SandboxPolicy.__init__(self)
        Sandbox.__init__(self, *args, **kwds)
        self.policy = self  # apply local policy rules

    def probe(self):
        # add custom entries into the probe dict
        d = Sandbox.probe(self, False)
        d['cpu'] = d['cpu_info'][0]
        d['mem'] = d['mem_info'][1]
        d['result'] = MiniSandbox.result_name.get(self.result, 'NA')
        return d

    def __call__(self, e, a):
        # handle SYSCALL/SYSRET events with local rules
        if e.type in (S_EVENT_SYSCALL, S_EVENT_SYSRET):
            scinfo = (e.data, e.ext0) if machine == 'x86_64' else e.data
            rule = self.sc_table.get(scinfo, self._KILL_RF)
            return rule(e, a)
        # bypass other events to base class
        return SandboxPolicy.__call__(self, e, a)

    def _CONT(self, e, a):  # continue
        a.type = S_ACTION_CONT
        return a

    def _KILL_RF(self, e, a):  # restricted func.
        a.type, a.data = S_ACTION_KILL, S_RESULT_RF
        return a


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.stderr.write("synopsis: python " + __file__ + " foo/bar.exe\n")
        sys.exit(os.EX_USAGE)
    sys.exit(main(sys.argv))
