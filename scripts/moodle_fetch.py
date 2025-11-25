import requests
import json
import time
from datetime import datetime

import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# --- CONFIGURATION ---
MOODLE_URL = os.getenv("MOODLE_URL", "https://moodle.tau.ac.il")
TOKEN = os.getenv("MOODLE_TOKEN")

if not TOKEN:
    raise ValueError("MOODLE_TOKEN not found in environment variables or .env file.")
# ---------------------

def get_upcoming_deadlines():
    endpoint = f"{MOODLE_URL}/webservice/rest/server.php"
    
    # We want events from "now" onwards
    now_timestamp = int(time.time())
    
    params = {
        'wstoken': TOKEN,
        'wsfunction': 'core_calendar_get_action_events_by_timesort',
        'moodlewsrestformat': 'json',
        'timesortfrom': now_timestamp,
        'limitnum': 10  # Get the next 10 items
    }
    
    try:
        response = requests.get(endpoint, params=params)
        response.raise_for_status() # Check for HTTP errors
        data = response.json()
        
        # Check for Moodle-level errors
        if 'exception' in data:
            print(f"❌ API Error: {data['message']}")
            return

        events = data.get('events', [])
        
        if not events:
            print("✅ Connection successful, but you have NO upcoming deadlines!")
            return

        print(f"📅 Found {len(events)} upcoming deadlines:\n")
        
        for event in events:
            # Parse the Unix timestamp into a readable date
            due_date = datetime.fromtimestamp(event['timesort'])
            formatted_date = due_date.strftime('%Y-%m-%d %H:%M')
            
            course_name = event.get('course', {}).get('fullname', 'Unknown Course')
            activity_name = event.get('name')
            url = event.get('viewurl')
            
            print(f"🔴 [Due: {formatted_date}]")
            print(f"   📝 Task: {activity_name}")
            print(f"   📚 Course: {course_name}")
            print(f"   🔗 Link: {url}")
            print("-" * 40)

    except Exception as e:
        print(f"❌ Python Error: {e}")

if __name__ == "__main__":
    get_upcoming_deadlines()