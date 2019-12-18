# -*- coding: utf-8 -*-
#!/usr/bin/env python
import os
import sys
from whatsopt_services.__main__ import main

if __name__ == "__main__":
    os.execv(main(sys.argv[1:]))
