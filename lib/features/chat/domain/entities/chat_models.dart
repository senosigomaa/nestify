import 'package:equatable/equatable.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? propertyTitle;
  final String? propertyPrice;
  final String? propertyImage;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.propertyTitle,
    this.propertyPrice,
    this.propertyImage,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        isUser,
        timestamp,
        propertyTitle,
        propertyPrice,
        propertyImage,
      ];
}

class ChatConversation extends Equatable {
  final String id;
  final String agentName;
  final String agentAvatar;
  final String developerOrAgency;
  final PropertyEntity? property;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.agentName,
    required this.agentAvatar,
    required this.developerOrAgency,
    this.property,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.messages,
  });

  ChatConversation copyWith({
    String? id,
    String? agentName,
    String? agentAvatar,
    String? developerOrAgency,
    PropertyEntity? property,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    List<ChatMessage>? messages,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      agentName: agentName ?? this.agentName,
      agentAvatar: agentAvatar ?? this.agentAvatar,
      developerOrAgency: developerOrAgency ?? this.developerOrAgency,
      property: property ?? this.property,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
        id,
        agentName,
        agentAvatar,
        developerOrAgency,
        property,
        lastMessage,
        lastMessageTime,
        unreadCount,
        messages,
      ];
}
