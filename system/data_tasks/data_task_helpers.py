import sys
from pathlib import Path

# This assumes that config is at the same level as duft
root_path = Path(__file__).parent.parent.parent.parent
sys.path.append("%s/duft" % root_path)
sys.path.append("%s/duft-server" % root_path)


def something():
    print("something")
    print(sys.path)