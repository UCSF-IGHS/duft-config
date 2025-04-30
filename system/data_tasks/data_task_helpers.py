import sys
from pathlib import Path
import asyncio

# Fix the Windows event loop warning BEFORE running the notebook
if sys.platform.startswith("win"):
    try:
        from asyncio import WindowsSelectorEventLoopPolicy
        asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())
    except ImportError:
        pass

# This assumes that config is at the same level as duft
root_path = Path(__file__).parent.parent.parent.parent
sys.path.append("%s/duft" % root_path)
sys.path.append("%s/duft-server" % root_path)


def something():
    print("something")
    print(sys.path)