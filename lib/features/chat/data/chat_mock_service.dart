import 'package:flutter/foundation.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import '../domain/entities/chat_models.dart';

/// Singleton service managing in-app chat conversations with real estate brokers and agents.
class ChatMockService {
  ChatMockService._internal() {
    _initPreloadedConversations();
  }

  static final ChatMockService instance = ChatMockService._internal();

  final ValueNotifier<List<ChatConversation>> conversationsNotifier =
      ValueNotifier<List<ChatConversation>>([]);

  final ValueNotifier<int> totalUnreadNotifier = ValueNotifier<int>(2);

  void _initPreloadedConversations() {
    final allProps = MockPropertiesData.rawProperties
        .map((j) => PropertyModel.fromJson(j))
        .toList();

    final prop1 = allProps.firstWhere(
      (p) => p.id == 'prop_001',
      orElse: () => allProps.first,
    );
    final prop2 = allProps.firstWhere(
      (p) => p.id == 'prop_002',
      orElse: () => allProps.first,
    );
    final prop7 = allProps.firstWhere(
      (p) => p.id == 'prop_007',
      orElse: () => allProps.first,
    );

    final conv1 = ChatConversation(
      id: 'conv_palm_hills',
      agentName: 'م. حسام الشناوي',
      agentAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      developerOrAgency: 'مستشار مبيعات بالم هيلز',
      property: prop1,
      lastMessage:
          'أهلاً بك أستاذ ساري، تم تأكيد موعد المعاينة يوم السبت القادم الساعة ١١:٠٠ ظهراً بالكمبوند.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 25)),
      unreadCount: 1,
      messages: [
        ChatMessage(
          id: 'm1_1',
          text:
              'السلام عليكم، أرغب بحجز موعد معاينة لوحدة بنتهاوس فاخر في بالم هيلز ورقمي هو 01206667376',
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
          propertyTitle: prop1.title,
          propertyPrice: prop1.formattedPrice,
          propertyImage: prop1.images.first,
        ),
        ChatMessage(
          id: 'm1_2',
          text:
              'وعليكم السلام ورحمة الله وبركاته يا فندم. يسعدنا استقبال حضرتك.',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
        ),
        ChatMessage(
          id: 'm1_3',
          text:
              'أهلاً بك أستاذ ساري، تم تأكيد موعد المعاينة يوم السبت القادم الساعة ١١:٠٠ ظهراً بالكمبوند.',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
      ],
    );

    final conv2 = ChatConversation(
      id: 'conv_sodic',
      agentName: 'سارة عبد العزيز',
      agentAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      developerOrAgency: 'إدارة مبيعات سوديك (SODIC VYE)',
      property: prop2,
      lastMessage:
          'بخصوص العرض الكاش للفيلا، الوحدة جاهزة للتسليم الفوري مع خصم ٢٢٪.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 1,
      messages: [
        ChatMessage(
          id: 'm2_1',
          text:
              'مرحباً، هل الفيلا كاش فقط أم يتوفر بها تسهيلات بنكية؟',
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        ChatMessage(
          id: 'm2_2',
          text:
              'بخصوص العرض الكاش للفيلا، الوحدة جاهزة للتسليم الفوري مع خصم ٢٢٪.',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    );

    final conv3 = ChatConversation(
      id: 'conv_madinaty',
      agentName: 'أحمد الشريف',
      agentAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
      developerOrAgency: 'إدارة إيجارات مدينتي طلعت مصطفى',
      property: prop7,
      lastMessage:
          'عقد الإيجار السنوي جاهز وشامل الصيانة ومواقف السيارات الخاصة.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      messages: [
        ChatMessage(
          id: 'm3_1',
          text: 'عقد الإيجار السنوي جاهز وشامل الصيانة ومواقف السيارات الخاصة.',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );

    conversationsNotifier.value = [conv1, conv2, conv3];
    _recalcUnread();
  }

  void _recalcUnread() {
    int total = 0;
    for (final c in conversationsNotifier.value) {
      total += c.unreadCount;
    }
    totalUnreadNotifier.value = total;
  }

  /// Starts or gets a conversation linked to a property inspection inquiry.
  ChatConversation startOrGetConversation({
    required PropertyEntity property,
    required String clientName,
    required String clientPhone,
    required String tourSlot,
    String? notes,
  }) {
    final list = List<ChatConversation>.from(conversationsNotifier.value);
    final convId = 'conv_${property.id}';
    final existingIndex = list.indexWhere((c) => c.id == convId);

    final now = DateTime.now();
    final firstMsg = ChatMessage(
      id: 'msg_${now.millisecondsSinceEpoch}',
      text:
          'السلام عليكم، أرغب بحجز موعد معاينة لوحدة [${property.title}]، الموعد المفضل: $tourSlot، ورقم هاتفي للتواصل: $clientPhone.${notes != null && notes.trim().isNotEmpty ? ' ملاحظات إضافية: $notes' : ''}',
      isUser: true,
      timestamp: now,
      propertyTitle: property.title,
      propertyPrice: property.formattedPrice,
      propertyImage: property.images.isNotEmpty ? property.images.first : null,
    );

    final agentResponse = ChatMessage(
      id: 'msg_${now.millisecondsSinceEpoch + 1}',
      text:
          'أهلاً بك يا أستاذ $clientName! تم استلام طلب المعاينة لوحدة ${property.title}. مستشار المبيعات سيتواصل معك عبر هذا الشات ورقم هاتفك لتأكيد تفاصيل الدخول للكمبوند.',
      isUser: false,
      timestamp: now.add(const Duration(seconds: 2)),
    );

    if (existingIndex >= 0) {
      final existing = list[existingIndex];
      final updated = existing.copyWith(
        property: property,
        lastMessage: agentResponse.text,
        lastMessageTime: now,
        messages: [...existing.messages, firstMsg, agentResponse],
      );
      list[existingIndex] = updated;
      conversationsNotifier.value = list;
      _recalcUnread();
      return updated;
    } else {
      final newConv = ChatConversation(
        id: convId,
        agentName: 'مستشار مبيعات ${property.compoundName}',
        agentAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        developerOrAgency: property.developerName,
        property: property,
        lastMessage: agentResponse.text,
        lastMessageTime: now,
        unreadCount: 0,
        messages: [firstMsg, agentResponse],
      );
      list.insert(0, newConv);
      conversationsNotifier.value = list;
      _recalcUnread();
      return newConv;
    }
  }

  void markAsRead(String conversationId) {
    final list = List<ChatConversation>.from(conversationsNotifier.value);
    final idx = list.indexWhere((c) => c.id == conversationId);
    if (idx >= 0 && list[idx].unreadCount > 0) {
      list[idx] = list[idx].copyWith(unreadCount: 0);
      conversationsNotifier.value = list;
      _recalcUnread();
    }
  }

  void sendMessage(String conversationId, String text) {
    if (text.trim().isEmpty) return;
    final list = List<ChatConversation>.from(conversationsNotifier.value);
    final idx = list.indexWhere((c) => c.id == conversationId);
    if (idx < 0) return;

    final now = DateTime.now();
    final newMsg = ChatMessage(
      id: 'msg_${now.millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: now,
    );

    final conv = list[idx];
    final updated = conv.copyWith(
      lastMessage: text.trim(),
      lastMessageTime: now,
      messages: [...conv.messages, newMsg],
    );
    list[idx] = updated;
    // Move to top
    list.removeAt(idx);
    list.insert(0, updated);
    conversationsNotifier.value = list;
  }
}
