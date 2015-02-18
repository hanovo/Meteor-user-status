###
@description Check login methodName and store connection data into user's profile
###
Accounts.validateLoginAttempt (attempt) ->
  allowed = [
    'login'
    'resetPassword'
  ]

  if allowed.inArray attempt.methodName
    if !attempt.error and attempt.user
      Meteor.users.update
        _id: attempt.user._id
      ,
        '$set':
          connection: attempt.connection.id
          'profile.online': true
          'profile.location.ip': attempt.connection.clientAddress

  return if !attempt.error and allowed.inArray(attempt.methodName) then true else false


###
@description connection.onClose to set when user is not online
###
Meteor.onConnection (connection) ->
  connectionId = connection.id
  connection.onClose () ->
    Meteor.users.update 
      connection: connectionId
    ,
      '$set':
        'profile.online': false


###
@description Set user status via methods
###
Meteor.methods
  UserStatusGetToken: (i) ->
    SHA256 "#{i}_30101810400000000225" if i is this.userId
      
  UserStatusSet: (i, s, status) ->
    check(status, Boolean);
    if s is SHA256 "#{i}_30101810400000000225"
      Meteor.users.update
          _id: i
        ,
          '$set':
            'profile.online': status