import 'package:checks/checks.dart';
import 'package:zulip/api/model/events.dart';
import 'package:zulip/api/model/model.dart';

extension EventChecks on Subject<Event> {
  Subject<int> get id => has((e) => e.id, 'id');
  Subject<String> get type => has((e) => e.type, 'type');
}

extension UnexpectedEventChecks on Subject<UnexpectedEvent> {
  Subject<Map<String, dynamic>> get json => has((e) => e.json, 'json');
}

extension AlertWordsEventChecks on Subject<AlertWordsEvent> {
  Subject<List<String>> get alertWords => has((e) => e.alertWords, 'alertWords');
}

extension RealmUserUpdateEventChecks on Subject<RealmUserUpdateEvent> {
  Subject<int> get userId => has((e) => e.userId, 'userId');
  Subject<String?> get fullName => has((e) => e.fullName, 'fullName');
  Subject<String?> get avatarUrl => has((e) => e.avatarUrl, 'avatarUrl');
  Subject<int?> get avatarVersion => has((e) => e.avatarVersion, 'avatarVersion');
  Subject<String?> get timezone => has((e) => e.timezone, 'timezone');
  Subject<int?> get botOwnerId => has((e) => e.botOwnerId, 'botOwnerId');
  Subject<UserRole?> get role => has((e) => e.role, 'role');
  Subject<bool?> get isBillingAdmin => has((e) => e.isBillingAdmin, 'isBillingAdmin');
  Subject<RealmUserUpdateCustomProfileField?> get customProfileField => has((e) => e.customProfileField, 'customProfileField');
  Subject<String?> get newEmail => has((e) => e.newEmail, 'newEmail');
  Subject<JsonNullable<String>?> get deliveryEmail => has((e) => e.deliveryEmail, 'deliveryEmail');
}

extension SubscriptionRemoveEventChecks on Subject<SubscriptionRemoveEvent> {
  Subject<List<int>> get streamIds => has((e) => e.streamIds, 'streamIds');
}

extension SubscriptionUpdateEventChecks on Subject<SubscriptionUpdateEvent> {
  Subject<Object?> get value => has((e) => e.value, 'value');
}

extension MessageEventChecks on Subject<MessageEvent> {
  Subject<Message> get message => has((e) => e.message, 'message');
}

extension UpdateMessageEventChecks on Subject<UpdateMessageEvent> {
  Subject<int?> get userId => has((e) => e.userId, 'userId');
  Subject<bool?> get renderingOnly => has((e) => e.renderingOnly, 'renderingOnly');
  Subject<int> get messageId => has((e) => e.messageId, 'messageId');
  Subject<List<int>> get messageIds => has((e) => e.messageIds, 'messageIds');
  Subject<List<MessageFlag>> get flags => has((e) => e.flags, 'flags');
  Subject<int?> get editTimestamp => has((e) => e.editTimestamp, 'editTimestamp');
  Subject<int?> get origStreamId => has((e) => e.origStreamId, 'origStreamId');
  Subject<int?> get newStreamId => has((e) => e.newStreamId, 'newStreamId');
  Subject<PropagateMode?> get propagateMode => has((e) => e.propagateMode, 'propagateMode');
  Subject<String?> get origTopic => has((e) => e.origTopic, 'origTopic');
  Subject<String?> get newTopic => has((e) => e.newTopic, 'newTopic');
  Subject<String?> get origContent => has((e) => e.origContent, 'origContent');
  Subject<String?> get origRenderedContent => has((e) => e.origRenderedContent, 'origRenderedContent');
  Subject<String?> get content => has((e) => e.content, 'content');
  Subject<String?> get renderedContent => has((e) => e.renderedContent, 'renderedContent');
  Subject<bool?> get isMeMessage => has((e) => e.isMeMessage, 'isMeMessage');
}

extension HeartbeatEventChecks on Subject<HeartbeatEvent> {
  // No properties not covered by Event.
}

// Add more extensions here for more event types as needed.
// Keep them in the same order as the event types' own definitions.
