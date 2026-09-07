import pytest
from api.client import APIClient
from data.test_data import TEST_USER


@pytest.fixture
def api_client():
    client = APIClient()
    client.post(
        "/index.php?route=account/login",
        data=TEST_USER
    )
    return client


@pytest.fixture
def guest_client():
    return APIClient()
