import pytest
from app import create_app

@pytest.fixture
def client():
    app = create_app()
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_status(client):
    response = client.get('/')
    assert response.status_code == 200

def test_register_fail(client):
    response = client.post('/register', json={})
    assert response.status_code == 400