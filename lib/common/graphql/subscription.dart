mixin Subscription {
  static String listenWallets = '''
    subscription listenWallets(\$user_uuid: String = "") {
      Wallet(where: {user_uuid: {_eq: \$user_uuid}}) {
        id
        expense_balance
        income_balance
        name
        type_wallet_id
        user_uuid
        is_loan_wallet
        TypeWallet {
          id
          icon
          name
        }
      }
    }
''';
  static String listenGoals = '''
    subscription listenGoals(\$user_uuid: String = "") {
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

  static String listenGoalById = '''
    subscription listenGoalById(\$id: Int = 10) {
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

  static String listenContract = '''
    subscription listenContract(\$email: String = "") {
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
  static String listenTransContract = '''
     subscription listenTranContract(\$email_lender: String = "") {
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
}
