import requests


def make_example_request():
    return requests.get(
        url='https://example.com',
    )


if __name__ == '__main__':
    print(make_example_request().content)

