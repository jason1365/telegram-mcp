from telethon.sync import TelegramClient
from telethon.sessions import StringSession

API_ID = int(input('Enter your TELEGRAM_API_ID: '))
API_HASH = input('Enter your TELEGRAM_API_HASH: ')

print('\nConnecting to Telegram...')
with TelegramClient(StringSession(), API_ID, API_HASH) as client:
    session_string = StringSession.save(client.session)
    print('\n=== SUCCESS ===')
    print('Session String:')
    print(session_string)
    print('\nAdd this to your .env file as:')
    print(f'TELEGRAM_SESSION_STRING={session_string}')