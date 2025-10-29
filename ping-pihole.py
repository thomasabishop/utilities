import base64
import getpass
import os
import socket
from datetime import datetime, timedelta

import requests

PIHOLE_IP = "192.168.68.53"
PIHOLE_PASSWORD = os.environ.get("PIHOLE_PASSWORD")
HOSTNAME = socket.gethostname()
USER = getpass.getuser()
NTFY_URL = "https://ntfy.systemsobscure.net/homelab"
NTFY_PASSWORD = os.environ.get("NTFY_PASSWORD")
NTFY_ENCODED_AUTH = f"Basic {base64.b64encode(f'thomas:{NTFY_PASSWORD}'.encode('utf-8')).decode('utf-8')}"
HOST_IP = socket.gethostbyname(HOSTNAME)


def get_authorisation_token():
    r = requests.post(
        f"http://{PIHOLE_IP}/api/auth",
        json={"password": PIHOLE_PASSWORD},
    )
    return r.json()["session"]["sid"]


def get_stats(headers):
    r = requests.get(f"http://{PIHOLE_IP}/api/stats/summary", headers=headers)
    return r.json()["queries"]


def convertUptime(seconds):
    duration = timedelta(seconds=seconds)
    days = duration.days
    hours = duration.seconds // 3600
    minutes = (duration.seconds % 3600) // 60
    secs = duration.seconds % 60
    since = datetime.now() - duration

    return {
        "days": days,
        "hours": hours,
        "minutes": minutes,
        "seconds": secs,
        "since": since.strftime("%a %d %b %Y %H:%M:%S"),
    }


def get_uptime(headers):
    r = requests.get(f"http://{PIHOLE_IP}/api/info/system", headers=headers)
    uptime_in_secs = r.json()["system"]["uptime"]
    return convertUptime(uptime_in_secs)


if __name__ == "__main__":
    ntfy_headers = {
        "Authorization": NTFY_ENCODED_AUTH,
        "Tags": f"{USER}@{HOSTNAME}({HOST_IP})",
    }

    try:
        auth_token = get_authorisation_token()
        headers = {"X-FTL-SID": auth_token}
        stats = get_stats(headers)
        uptime = get_uptime(headers)
        message = f"""🟩 pihole@{PIHOLE_IP} is up.\nTotal queries blocked: {stats["blocked"]} of {stats["total"]} ({round(stats["percent_blocked"])}%)\nUptime: {uptime["days"]} days, {uptime["hours"]} hours, {uptime["minutes"]} minutes (since {uptime["since"]}) 
    """
        requests.post(
            NTFY_URL,
            data=message,
            headers=ntfy_headers,
        )
    except (requests.exceptions.ConnectionError, requests.exceptions.Timeout):
        requests.post(
            NTFY_URL, data=f"🟥 pihole@{PIHOLE_IP} is down.", headers=ntfy_headers
        )
    except Exception as e:
        print(f"TB-ERROR: Error fetching Pihole stats and status: {e}")
