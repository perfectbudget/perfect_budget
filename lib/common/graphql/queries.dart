mixin Queries {
  static String getUser = '''
    query GetUser(\$uuid: String = "") {
      User(where: {uuid: {_eq: \$uuid}}) {
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
  ''';

  static String getUserByEmail = '''
    query GetUser(\$email: String = "") {
      User(where: {email: {_eq: \$email}}) {
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
  ''';

  static String getWallets = '''
    query GetWallets(\$user_uuid: String = "") {
      Wallet(where: {user_uuid: {_eq: \$user_uuid}}) {
        id
        user_uuid
        name
        type_wallet_id
        income_balance
        expense_balance
        is_loan_wallet
        TypeWallet {
          id
          name
          icon
        }
      }
    }
  ''';

  static String getContracts = '''
    query GetContract(\$email: String = "") {
      Contract(where: {_or: [{email_lender: {_eq: \$email}}, {email_borrower: {_eq: \$email}}]}, order_by: {updated_at: desc}) {
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
        Transactions(where: {Wallet: {User: {email: {_eq: \$email}}}}) {
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
            parrent_id
            name
            icon
            type
            is_default
          }
        }
      }
    }

  ''';

  static String getTransContract = '''
   query getTranContract(\$email_lender: String = "") {
      TransactionContract(where: {Contract: {email_lender: {_eq:\$email_lender}}}, order_by: {updated_at: desc}) {
        id
        money_paid
        contract_id
        note
        pay_date
        status
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
          Transactions(where: {Wallet: {User: {email: {_eq: \$email_lender}}}}) {
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
              parrent_id
              name
              icon
              type
              is_default
            }
          }
        }
      }
    }
''';

  static String getTransactionsByWalletId = '''
    query GetTransactions(\$walletId: Int = 1) {
      Transaction(where: {wallet_id: {_eq: \$walletId}}, order_by: {date: desc}) {
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
          parrent_id
          name
          icon
          type
          is_default
        }
      }
  }
''';

  static String getAllTransactions = '''
   query GetTransactions(\$user_uuid: String = "", \$_gte: timestamp = "", \$_lte: timestamp = "") {
      Transaction(where: {Wallet: {user_uuid: {_eq: \$user_uuid}}, date: {_gte: \$_gte, _lte: \$_lte}}, order_by: {date: desc}) {
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
          parrent_id
          name
          icon
          type
          is_default
        }
      }
    }

''';

  static String getCategories = '''
    query GetCategories {
      Category {
        id
        parrent_id
        name
        icon
        type
        is_default
      }
    }
  ''';
  static String getTypeWallet = '''
    query GetTypeWallet {
      TypeWallet {
        id
        name
        icon
      } 
    }
''';
  static String getAllGoals = '''
    query GetAllGoals(\$user_uuid: String = "") {
      Goal(order_by: {updated_at: desc}, where: {user_uuid: {_eq: \$user_uuid}}) {
        id
        name
        money_saving
        money_goal
        days
        time_end
        time_start
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
  static String getGoalById = '''
    query GetGoalById(\$id: Int = 10) {
      Goal(where: {id: {_eq: \$id}}) {
        id
        name
        money_saving
        money_goal
        days
        time_end
        time_start
        Category {
          id
          parrent_id
          name
          icon
          type
          is_default
        }
        TransactionGoals {
          id
          balance
          date
          goal_id
          note
        }
      }
    }
''';
}
