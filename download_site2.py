import os
import requests
from urllib.parse import urljoin, urlparse
from bs4 import BeautifulSoup
from urllib3.exceptions import InsecureRequestWarning

# 关闭SSL警告
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

# 设置User-Agent为Firefox浏览器
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0'
}

def download_file(url, local_path, auth=None):
    """Download a file from a given URL to a local path."""
    try:
        with requests.get(url, headers=headers, stream=True, verify=False, auth=auth) as response:
            response.raise_for_status()
            with open(local_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred while downloading {url}: {http_err}")
    except Exception as e:
        print(f"Error downloading {url}: {e}")

def get_links_from_html(html_content, base_url):
    """Extract all href links from the HTML content."""
    soup = BeautifulSoup(html_content, 'html.parser')
    links = []
    for a_tag in soup.find_all('a', href=True):
        href = a_tag['href']
        if href == '../': # ignore the ../
            continue
        full_url = urljoin(base_url, href)
        links.append(full_url)
    return links

def is_directory(url, auth=None):
    """Check if the URL points to a directory by examining its contents."""
    try:
        response = requests.get(url, headers=headers, verify=False, auth=auth)
        response.raise_for_status()
        links = get_links_from_html(response.text, url)
        # A directory typically contains subdirectories or files
        return any(link.endswith('/') for link in links)
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred while checking directory {url}: {http_err}")
        return False
    except Exception as e:
        print(f"Error checking directory {url}: {e}")
        return False

def download_site(base_url, local_base_dir, auth=None):
    """Recursively download an entire site starting from base_url to local_base_dir."""
    if not os.path.exists(local_base_dir):
        os.makedirs(local_base_dir)

    try:
        response = requests.get(base_url, headers=headers, verify=False, auth=auth)
        response.raise_for_status()
        links = get_links_from_html(response.text, base_url)

        for link in links:
            relative_path = link[len(base_url):].strip('/')
            local_item_path = os.path.join(local_base_dir, relative_path)
            
            #if is_directory(link, auth=auth):
            if link.endswith('/'):
                print(f"Processing directory: {link} -> {local_item_path}")
                download_site(link, local_item_path, auth=auth)
            else:
                print(f"Downloading file: {link} -> {local_item_path}")
                os.makedirs(os.path.dirname(local_item_path), exist_ok=True)
                download_file(link, local_item_path, auth=auth)
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
    except Exception as e:
        print(f"Error processing {base_url}: {e}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3 or len(sys.argv) > 5:
        print("Usage: python download_site2.py <https://svn.xvid.org/trunk/xvidcore/> <local_directory> [<username>] [<password>]")
        sys.exit(1)

    remote_url = sys.argv[1]
    local_directory = sys.argv[2]
    username = sys.argv[3] if len(sys.argv) > 3 else None
    password = sys.argv[4] if len(sys.argv) > 4 else None

    # 默认使用 anonymous 用户名和空密码 
    auth = ('anonymous', '') if username is None and password is None else (username, password)
    download_site(remote_url, local_directory, auth=auth)
    # python download_site2.py https://svn.xvid.org/trunk/xvidcore/ xvid_cache