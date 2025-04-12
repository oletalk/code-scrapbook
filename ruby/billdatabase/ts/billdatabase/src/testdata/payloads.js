export function getMainScreenPayments() {
  return [
    {
      "name":"MacFie & Co",
      "summary":"Quarterly Common Charges from 01/06 to 31/08",
      "due_date":"2024-09-09",
      "paid_date":"",
      "document_id":"35",
      "status":"unpaid"
    }
  ]
}

export function getTags() {
  return [
    {
      "json_class": "SenderTag",
      "id": "2",
      "description": "second",
      "color": "#00ff00"
    },
    {
      "json_class": "SenderTag",
      "id": "1",
      "description": "first",
      "color": "#ff0000"
    }
  ]
}

export function getAllSendersWithTags() {
  return [
    {
      "json_class": "Sender",
      "id": "1",
      "name": "ACME Corporation",
      "created_at": "2023-04-01 18:52:55.432225",
      "username": "",
      "password_hint": "",
      "comments": "my employer",
      "is_active": true,
      "sender_accounts": [],
      "sender_contacts": [],
      "sender_tags": [
        {
          "json_class": "SenderTag",
          "id": "1",
          "description": "first",
          "color": "#ff0000"
        }
      ]
    },
    {
      "json_class": "Sender",
      "id": "6",
      "name": "Foobar Insurance LLC",
      "created_at": "2023-04-04 19:59:26.994918",
      "username": "freddy",
      "password_hint": "password daughter's birthday",
      "comments": "home insurance",
      "is_active": true,
      "sender_accounts": [],
      "sender_contacts": [],
      "sender_tags": [
        {
          "json_class": "SenderTag",
          "id": "2",
          "description": "second",
          "color": "#00ff00"
        }
      ]
    },
    {
      "json_class": "Sender",
      "id": "19",
      "name": "Stonks Inc.",
      "created_at": "2023-04-07 15:46:52.745451",
      "username": "201091192876",
      "password_hint": "pin on app is ssn",
      "comments": "username is membership number",
      "is_active": true,
      "sender_accounts": [],
      "sender_contacts": [],
      "sender_tags": [
        {
          "json_class": "SenderTag",
          "id": "2",
          "description": "second",
          "color": "#00ff00"
        }
      ]
    }]

}

export function simpleOkResponse() {
  return {
    ok: true,
    status: 200,
    json: async () => ({}),
  }
}

export function OkResponse(json) {
  return {
    ok: true,
    status: 200,
    json: async () => (json),
  }
}