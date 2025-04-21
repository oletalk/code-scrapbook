export function getMainScreenPayments() {
  return [
    {
      "name":"Lorem Ipsum LLC",
      "summary":"Quarterly Common Charges from 01/06 to 31/08",
      "due_date":"2024-09-09",
      "paid_date":"",
      "document_id":"35",
      "status":"unpaid"
    }
  ]
}

/** documents for sender id 11 */
export function getSenderDocuments() {
  return [
    {
        "json_class": "Document",
        "id": "42",
        "created_at": null,
        "received_date": "2025-03-05",
        "summary": "Invoice 234",
        "due_date": "2025-03-19",
        "paid_date": "2025-03-07",
        "doc_type": {
            "json_class": "DocType",
            "id": "7",
            "name": "Invoice"
        },
        "sender": {
            "json_class": "Sender",
            "id": "11",
            "name": "Lorem Ipsum LLC",
            "created_at": null,
            "username": null,
            "password_hint": null,
            "comments": null,
            "is_active": false,
            "sender_accounts": [],
            "sender_contacts": [],
            "sender_tags": []
        },
        "comments": "",
        "sender_account": {
            "json_class": "SenderAccount",
            "id": "2",
            "sender_id": "1",
            "account_number": "2222",
            "account_details": null,
            "closed": false,
            "comments": null
        },
        "file_location": "42/dfdfd.pdf"
    },
    {
        "json_class": "Document",
        "id": "37",
        "created_at": null,
        "received_date": "2024-12-05",
        "summary": "Invoice 459",
        "due_date": "2024-12-05",
        "paid_date": "2024-12-07",
        "doc_type": {
            "json_class": "DocType",
            "id": "7",
            "name": "Invoice"
        },
        "sender": {
            "json_class": "Sender",
            "id": "1",
            "name": "Lorem Ipsum LLC",
            "created_at": null,
            "username": null,
            "password_hint": null,
            "comments": null,
            "is_active": false,
            "sender_accounts": [],
            "sender_contacts": [],
            "sender_tags": []
        },
        "comments": "",
        "sender_account": {
            "json_class": "SenderAccount",
            "id": "2",
            "sender_id": "1",
            "account_number": "123",
            "account_details": null,
            "closed": false,
            "comments": null
        },
        "file_location": "37/erfgf.pdf"
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

export function getADocument() {
  return {
    "json_class": "Document",
    "id": "23",
    "created_at": null,
    "received_date": "2023-05-13",
    "summary": "Pension statement at 31/12/2022",
    "due_date": null,
    "paid_date": null,
    "doc_type": {
      "json_class": "DocType",
      "id": "4",
      "name": "Statement"
    },
    "sender": {
      "json_class": "Sender",
      "id": "1",
      "name": "Lorem Ipsum LLC",
      "created_at": null,
      "username": null,
      "password_hint": null,
      "comments": null,
      "is_active": false,
      "sender_accounts": [],
      "sender_contacts": [],
      "sender_tags": []
  },
"comments": "",
    "sender_account": null,
    "file_location": "23/VZfPvg.jpeg"
  }
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