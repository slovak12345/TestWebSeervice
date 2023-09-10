import logging
import sys
from pythonjsonlogger import jsonlogger
import threading
import time

def thread1():
    print("Thread 1 started")
    logger1 = logging.getLogger('app1')
    logger1.setLevel(logging.INFO)

    file1_handler = logging.FileHandler("app1.log")
    file1_handler.setFormatter(format_output)
    logger1.addHandler(file1_handler)

    for i in range(0, 10):
        logger1.debug(f"{i}:This a debug message")
        logger1.info(f"{i}:This is an info message")
        logger1.warning(f"{i}:This is a warning message")
        logger1.error(f"{i}:This is an error message")
        logger1.critical(f"{i}:This is a critical message")
        time.sleep(2)
    print("Thread 1 finished")
def thread2():
    print("Thread 2 started")
    logger2 = logging.getLogger('app2')
    logger2.setLevel(logging.INFO)

    file2_handler = logging.FileHandler("app2.log")
    file2_handler.setFormatter(format_output)
    logger2.addHandler(file2_handler)

    for i in range(0, 40):
        logger2.debug(f"{i}:This a debug message")
        logger2.info(f"{i}:This is an info message")
        logger2.warning(f"{i}:This is a warning message")
        logger2.error(f"{i}:This is an error message")
        logger2.critical(f"{i}:This is a critical message")
        time.sleep(1)
    print("Thread 2 finished")
#logging.basicConfig()
#logger = logging.getLogger('log_example')
#logger.setLevel(logging.INFO)

#stdout_handler = logging.StreamHandler(stream=sys.stdout)
#format_output = logging.Formatter('%(levelname)s : %(name)s : %(message)s : %(asctime)s')
# format with JSON
format_output = jsonlogger.JsonFormatter('%(levelname)s : %(name)s : %(message)s : %(asctime)s : %(pathname)s')
## Creat a stdout handler
#stdout_handler.setFormatter(format_output)
#logger.addHandler(stdout_handler)

## Create a file handler
#file_handler = logging.FileHandler("app.log")
#file_handler.setFormatter(format_output)
#logger.addHandler(file_handler)

th1 = threading.Thread(target=thread1)
th2 = threading.Thread(target=thread2)

th1.start()
th2.start()

