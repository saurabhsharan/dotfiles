#!/opt/homebrew/bin/python3

import sys
from urllib.parse import urljoin, urlparse, parse_qs

def is_url(s):
  return s.startswith('https://')

def convert_url(url):
  p = urlparse(url)
  if 'amazon.com' in p.netloc:
    new_url = urljoin(url, p.path.replace('gp/product', 'dp'))
    return new_url
  elif 'youtube.com' in p.netloc:
    queryDict = parse_qs(p.query)
    if 'v' not in queryDict:
      return
    new_url = 'https://youtube.com/watch?v=%s' % (queryDict['v'][0],)
    return new_url

in_text = sys.stdin.read().strip()

if is_url(in_text):
  new_url = convert_url(in_text)
  if new_url:
    print(new_url, end="")
  else:
    print(in_text, end="")
else:
  print(in_text.replace("\n", " "), end="")
