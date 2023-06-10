mixin Mutations {
  static String insertUser() {
    return '''mutation InsertUserOne(\$uuid: String = "", \$name: String = "", \$email: String = "", \$avatar: String = "", \$currency_code: String = "", \$currency_symbol: String = "") {
      insert_User_one(object: {uuid: \$uuid, name: \$name, email: \$email, avatar: \$avatar, currency_code: \$currency_code, currency_symbol: \$currency_symbol}) {
        id
        name
        email
        uuid
        currency_code
        currency_symbol
        avatar
        language
        Currency {
          id
          name
          description
          code
        }
      }
    }
''';
  }

  static String updateCurencyUser() {
    return '''mutation UpdateUser(\$uuid: String = "", \$currency_code: String = "", \$currency_symbol: String = "") {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {currency_code: \$currency_code, currency_symbol: \$currency_symbol}) {
        returning {
          id
          email
          name
          uuid
          currency_code
          currency_symbol
          avatar
          date_premium
          language
        }
      }
    }
''';
  }

  static String updatePremiumUser() {
    return '''mutation UpdateUser(\$uuid: String = "", \$date_premium: timestamp = "") {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {date_premium: \$date_premium}) {
        returning {
          id
          email
          name
          uuid
          currency_code
          currency_symbol
          avatar
          date_premium
          language
        }
      }
    }
''';
  }

  static String updateLanguageUser() {
    return '''mutation UpdateUser(\$uuid: String = "", \$language: String = "") {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {language: \$language}) {
        returning {
          id
          email
          name
          uuid
          currency_code
          currency_symbol
          avatar
          date_premium
          language
        }
      }
    }
''';
  }

  static String deleteUser() {
    return '''mutation DeleteUser(\$uuid: String = "") {
      delete_User(where: {uuid: {_eq: \$uuid}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String createWallet() {
    return '''mutation InsertWallet(\$name: String = "", \$type_wallet_id: Int = 10, \$income_balance: float8 = "", \$expense_balance: float8 = "", \$user_uuid: String = "") {
      insert_Wallet_one(object: {name: \$name, type_wallet_id: \$type_wallet_id, income_balance: \$income_balance, expense_balance: \$expense_balance, user_uuid: \$user_uuid}) {
        id
        income_balance
        expense_balance
        name
        type_wallet_id
        is_loan_wallet
        user_uuid
        TypeWallet {
          id
          icon
          name
        }
      }
    }
''';
  }

  static String updateWallet() {
    return '''mutation UpdateWallet(\$id: Int = 10, \$type_wallet_id: Int = 10, \$name: String = "") {
      update_Wallet(where: {id: {_eq: \$id}}, _set: {type_wallet_id: \$type_wallet_id, name: \$name}) {
        returning {
          id
          income_balance
          expense_balance
          name
          type_wallet_id
          is_loan_wallet
          user_uuid
          TypeWallet {
            id
            icon
            name
          }
        }
      }
    }
''';
  }

  static String removeWallet() {
    return '''mutation DeleteWallet(\$id: Int = 10) {
      delete_Wallet(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String createTransaction() {
    return '''mutation InsertTransactionOne(\$wallet_id: Int = 10, \$category_id: Int = 10, \$balance: float8 = "", \$date: timestamp = "", \$note: String = "", \$type: TypeTransaction_enum = expense, \$photo_url: String = "") {
      insert_Transaction_one(object: {wallet_id: \$wallet_id, category_id: \$category_id, balance: \$balance, date: \$date, note: \$note, type: \$type, photo_url: \$photo_url}) {
        id
        wallet_id
        category_id
        balance
        type
        date
        note
        photo_url
        Category {
          id
          parrent_id
          name
          icon
          type
          is_default
        }
      }
    }
''';
  }

  static String updateTransaction() {
    return '''mutation UpdateTransaction(\$id: Int = 10, \$balance: float8 = "", \$category_id: Int = 10, \$date: timestamp = "", \$note: String = "", \$type: TypeTransaction_enum = expense, \$wallet_id: Int = 10, \$photo_url: String = "") {
      update_Transaction(where: {id: {_eq: \$id}}, _set: {balance: \$balance, category_id: \$category_id, date: \$date, note: \$note, type: \$type, wallet_id: \$wallet_id, photo_url: \$photo_url}) {
        returning {
          id
          wallet_id
          category_id
          balance
          date
          note
          type
          photo_url
          Category {
            id
            name
            type
            parrent_id
            icon
            is_default
          }
        }
      }
    }
''';
  }

  static String removeTransaction() {
    return '''mutation DeleteTransaction(\$id: Int = 10) {
      delete_Transaction(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String insertContract() {
    return '''mutation InsertContract(\$email_borrower: String = "", \$email_lender: String = "", \$money: Int = 10, \$status: String = "", \$real_money_to_pay: Int = 10, \$interest_rate: float8 = "", \$is_send_mail: Boolean = false, \$is_send_notify: Boolean = false, \$avatar_borrower: String = "",\$avatar_lender: String = "", \$name_contract: String = "") {
      insert_Contract_one(object: {email_borrower: \$email_borrower, email_lender: \$email_lender, money: \$money, status: \$status, real_money_to_pay: \$real_money_to_pay, interest_rate: \$interest_rate, is_send_mail: \$is_send_mail, is_send_notify: \$is_send_notify, avatar_borrower: \$avatar_borrower, avatar_lender: \$avatar_lender, name_contract: \$name_contract}) {
        id
        interest_rate
        is_send_mail
        is_send_notify
        money
        real_money_to_pay
        status
        email_borrower
        email_lender
        avatar_borrower
        avatar_lender
        name_contract
        Lender {
          id
          name
          email
          uuid
          currency_code
          currency_symbol
          avatar
          language
          date_premium
        }
      }
    }
    ''';
  }

  static String insertTranContract() {
    return '''mutation InsertTranContract(\$contract_id: Int = 10, \$money_paid: Int = 10, \$note: String = "", \$pay_date: timestamp = "", \$status: String = "") {
      insert_TransactionContract_one(object: {contract_id: \$contract_id, money_paid: \$money_paid, note: \$note, pay_date: \$pay_date, status: \$status}) {
        id
        money_paid
        note
        pay_date
        status
        contract_id
        Contract {
          id
          interest_rate
          is_send_mail
          is_send_notify
          money
          real_money_to_pay
          status
          email_borrower
          email_lender
          avatar_borrower
          name_contract
          Lender {
            id
            name
            email
            uuid
            currency_code
            currency_symbol
            avatar
            language
            date_premium
          }
        }
      }
    }
    ''';
  }

  static String updateContract() {
    return '''mutation UpdateContract(\$id: Int = 10, \$status: String = "") {
      update_Contract(where: {id: {_eq: \$id}}, _set: {status: \$status}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String removeContract() {
    return '''
      mutation DeleteContract(\$id: Int = 10) {
        delete_Contract(where: {id: {_eq: \$id}}) {
          returning {
            id
          }
        }
      }
    ''';
  }

  static String updateTransContract() {
    return '''mutation UpdateTransContract(\$id: Int = 10, \$status: String = "") {
      update_TransactionContract(where: {id: {_eq: \$id}}, _set: {status: \$status}) {
        returning {
          id
          money_paid
          note
          pay_date
          status
          contract_id
          Contract {
            id
            interest_rate
            is_send_mail
            is_send_notify
            money
            real_money_to_pay
            status
            email_borrower
            email_lender
            avatar_borrower
            name_contract
            Lender {
              id
              name
              email
              uuid
              currency_code
              currency_symbol
              avatar
              language
              date_premium
            }
          }
        }
      }
    }
''';
  }

  static String removeTransContract() {
    return '''
      mutation DeleteTransactionContract(\$id: Int = 10) {
        delete_TransactionContract(where: {id: {_eq: \$id}}) {
          returning {
            id
          }
        }
      }
    ''';
  }

  static String insertGoal() {
    return '''
      mutation InsertGoal(\$name: String = "", \$days: Int = 10, \$money_saving: float8 = "", \$money_goal: float8 = "", \$time_end: timestamp = "", \$time_start: timestamp = "", \$user_uuid: String = "", \$category_id: Int = 10) {
        insert_Goal_one(object: {name: \$name, days: \$days, money_saving: \$money_saving, money_goal: \$money_goal, time_end: \$time_end, time_start: \$time_start, user_uuid: \$user_uuid, category_id: \$category_id}) {
          id
        }
      }
  ''';
  }

  static String updateGoal() {
    return '''
      mutation UpdateGoal(\$days: Int = 10, \$category_id: Int = 10, \$money_goal: float8 = "", \$name: String = "", \$time_end: timestamp = "", \$user_uuid: String = "", \$id: Int = 10) {
        update_Goal(where: {user_uuid: {_eq: \$user_uuid}, id: {_eq: \$id}}, _set: {days: \$days, category_id: \$category_id, money_goal: \$money_goal, name: \$name, time_end: \$time_end}) {
          returning {
            id
          }
        }
      }
  ''';
  }

  static String updateMoneySavingGoal() {
    return '''
      mutation UpdateMoneySavingGoal(\$money_saving: float8 = "", \$id: Int = 10) {
        update_Goal(where: {id: {_eq: \$id}}, _set: {money_saving: \$money_saving}) {
          returning {
            id
          }
        }
      }
  ''';
  }

  static String deleteGoal() {
    return '''
      mutation DeleteGoal(\$id: Int = 10) {
        delete_Goal(where: {id: {_eq: \$id}}) {
          returning {
            id
          }
        }
      }
  ''';
  }

  static String insertTransactionGoal() {
    return '''
      mutation InsertTransactionGoal(\$balance: float8 = "", \$goal_id: Int = 10, \$note: String = "") {
        insert_TransactionGoal_one(object: {balance: \$balance, goal_id: \$goal_id, note: \$note}) {
          id
          goal_id
          date
          balance
          note
        }
      }
  ''';
  }

  static String updateTransactionGoal() {
    return '''
      mutation UpdateTransactionGoal(\$balance: float8 = "", \$note: String = "", \$id: Int = 10) {
        update_TransactionGoal(where: {id: {_eq: \$id}}, _set: {balance: \$balance, note: \$note}) {
          returning {
            id
          }
        }
      }
  ''';
  }

  static String deleteTransactionGoal() {
    return '''
      mutation DeleteTransactionGoal(\$id: Int = 10) {
        delete_TransactionGoal(where: {id: {_eq: \$id}}) {
          returning {
            id
          }
        }
      }
  ''';
  }
}
