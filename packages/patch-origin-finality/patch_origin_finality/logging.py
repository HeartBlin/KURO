INFO = "\033[95m"
OK = "\033[92m"
WARN = "\033[93m"
ERROR = "\033[91m"
RESET = "\033[0m"

def LOGI(tag, given_str):
    print(f"{INFO}I  {tag}: {given_str}{RESET}")

def LOGO(tag, given_str):
    print(f"{OK}OK {tag}: {given_str}{RESET}")

def LOGW(tag, given_str):
    print(f"{WARN}W  {tag}: {given_str}{RESET}")

def LOGE(tag, given_str):
    print(f"{ERROR}E  {tag}: {given_str}{RESET}")
