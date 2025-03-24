import 'package:chatting_app_flutter/data/repositories/auth_repository.dart';
import 'package:chatting_app_flutter/data/repositories/chat_repository.dart';
import 'package:chatting_app_flutter/data/repositories/contact_repository.dart';
import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_cubit.dart';
import 'package:chatting_app_flutter/presentation/pages/auth/login_screen.dart';
import 'package:chatting_app_flutter/presentation/pages/chat/chat_message_screen.dart';
import 'package:chatting_app_flutter/presentation/widgets/chat_list_tile.dart';
import 'package:chatting_app_flutter/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;
  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    _currentUserId = getIt<AuthRepository>().currentuser?.uid ?? "";
    super.initState();
  }

  showContacts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Contacts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _contactRepository.getRegisteredContact(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final contacts = snapshot.data!;
                  if (contacts.isEmpty) {
                    Text('No Contacts yet');
                  }
              
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(contact["name"][0].toString()),
                        ),
                        title: Text(
                          contact['name'],
                        ),
                        onTap: () {
                          getIt<AppRouter>().push(ChatMessageScreen(
                            receiverId: contact['id'],
                            receiverName: contact['name'],
                          ));
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Chats'),
          actions: [
            IconButton(
              onPressed: () async {
                await getIt<AuthCubit>().signOut();
                getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.9),
            onPressed: () {
              showContacts(context);
            },
            child: Icon(
              Icons.chat,
              color: Colors.white,
            )),
        body: StreamBuilder(
            stream: _chatRepository.getChatRoom(_currentUserId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error${snapshot.error}"),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              // if (!snapshot.hasData) {
              //   Center(
              //     child: CircularProgressIndicator(),
              //   );
              // }
              final chats = snapshot.data!;
              if (chats.isEmpty) {
                return Center(
                  child: Text("No Recent Chats"),
                );
              }
              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ChatListTile(
                      chat: chat, currentUserId: _currentUserId, onTap: () {});
                },
              );
            }));
  }
}
