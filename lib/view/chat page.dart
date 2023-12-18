import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class ChatViewScreen extends StatefulWidget {
  final String uid;
  final String vuid;
  final String vname;
  final String ptitle;
  final String prouid;

  ChatViewScreen({
    required this.uid,
    required this.vuid,
    required this.vname,
    required this.ptitle,
    required this.prouid,
  });

  @override
  _ChatViewScreenState createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  int batchSize = 10;
  int currentBatchSize = 10;
  String url = '';

  Future<void> _handleVideoSelection() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
        barrierDismissible: false,
      );

      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('chat_videos')
          .child('${DateTime.now()}.mp4');
      UploadTask uploadTask = storageReference.putFile(File(pickedVideo.path));

      await uploadTask.whenComplete(() {
        Navigator.of(context).pop();

        storageReference.getDownloadURL().then((fileURL) {
          setState(() {});
          sendMessage(messageText, '', widget.uid, widget.vuid, fileURL);
          sendMessage(messageText, '', widget.vuid, widget.uid, fileURL);
        });
      });

      uploadTask.catchError((error) {
        print(error);
      });
    }
  }

  void _handleImageSelection() async {
    final ImagePicker _picker = ImagePicker();
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
        barrierDismissible: false,
      );

      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('${DateTime.now()}.jpg');
      UploadTask uploadTask = storageReference.putFile(File(pickedImage.path));

      uploadTask.whenComplete(() {
        Navigator.of(context).pop();

        storageReference.getDownloadURL().then((fileURL) {
          setState(() {
            url = fileURL;
          });
          sendMessage(messageText, url, widget.uid, widget.vuid, '');
          sendMessage(messageText, url, widget.vuid, widget.uid, '');
        });
      });

      uploadTask.catchError((error) {
        print(error);
      });
    }
  }

  String messageText = '';

  Future<void> sendMessage(String messageText, String imageUrl, String sender,
      String reciever, String video) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(sender)
        .collection('AllChats')
        .doc(reciever)
        .collection('Chats')
        .add({
      'ImageUrl': imageUrl,
      'Videourl': video,
      'Text': messageText, // Set the message text
      'Timestamp': DateTime.now(),
      'SenderId': FirebaseAuth.instance.currentUser!.uid,
    }).then((value) {
      _textEditingController.clear();
      messageText = '';
    }).catchError((error) {
      print("Failed to send message: $error");
    });
  }

  void deleteMessage(String messageId, String sender, String reciever) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(sender)
        .collection('AllChats')
        .doc(reciever)
        .collection('Chats')
        .doc(messageId)
        .delete()
        .then((value) {
      print("Message deleted successfully");
    }).catchError((error) {
      print("Failed to delete message: $error");
    });
  }

  Stream<QuerySnapshot> getMessages() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.uid)
        .collection('AllChats')
        .doc(widget.vuid)
        .collection('Chats')
        .orderBy('Timestamp', descending: true)
        .limit(currentBatchSize)
        .snapshots();
  }

  void loadMoreMessages() {
    currentBatchSize += batchSize;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.ptitle ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.vname),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getMessages(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[200],
                      ),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var isCurrentUser = message['SenderId'] ==
                        FirebaseAuth.instance.currentUser!.uid;
                    var time = (message['Timestamp'] as Timestamp).toDate();
                    var formattedTime = DateFormat.Hm().format(time);

                    var imageUrl = isCurrentUser ? null : widget.ptitle;

                    return Dismissible(
                      key: Key(message.id),
                      // Use a unique key for each message
                      direction: isCurrentUser
                          ? DismissDirection.endToStart
                          : DismissDirection.startToEnd,
                      background: Container(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        deleteMessage(
                            message.id,
                            widget.uid,
                            widget
                                .vuid); // Call the function to delete the message
                        deleteMessage(
                            message.id,
                            widget.vuid,
                            widget
                                .uid); // Call the function to delete the message
                      },
                      child: Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.5,
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blueAccent.withOpacity(0.8)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (!isCurrentUser && imageUrl != null)
                                CircleAvatar(
                                  backgroundImage: NetworkImage(imageUrl),
                                  radius: 15,
                                ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (message['ImageUrl'] != '')
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              1.7,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: PhotoView(
                                                        imageProvider:
                                                            NetworkImage(message[
                                                                'ImageUrl']),
                                                        // minScale: PhotoViewComputedScale.contained * 0.8,
                                                        // maxScale: PhotoViewComputedScale.covered * 2,
                                                        // initialScale: PhotoViewComputedScale.contained,
                                                        //customSize: Size(200, 200),
                                                        backgroundDecoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          child: IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          color: Colors.red,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Image.network(
                                          message['ImageUrl'],
                                          width: 150, // Adjust the image width
                                        ),
                                      ),
                                    if (message['Videourl'] != '')
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              1.7,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: VideoApp(
                                                        videoUrl:
                                                            message['Videourl'],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          child: IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          color: Colors.red,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          child: VideoApp(
                                            videoUrl: message['Videourl'],
                                          ),
                                        ),
                                      ),
                                    if (message['Text'] != null)
                                      Text(
                                        message['Text'],
                                        style: TextStyle(
                                          color: isCurrentUser
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isCurrentUser
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              if (isCurrentUser && imageUrl != null)
                                CircleAvatar(
                                  backgroundImage: NetworkImage(imageUrl),
                                  radius: 15,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _textEditingController,
                  onChanged: (value) {
                    messageText = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter message',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(width: 1.0, color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(width: 1.0, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(width: 2.0, color: Colors.blue),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.message),
                    ),
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                            onTap: () async {
                              if (messageText.isNotEmpty) {
                                await sendMessage(messageText, '', widget.uid,
                                    widget.vuid, '');
                                await sendMessage(messageText, '', widget.vuid,
                                    widget.uid, '');
                                setState(() {
                                  messageText = '';
                                });
                              }
                            },
                            child: Icon(CupertinoIcons.paperplane_fill,
                                color: Colors.blue)),
                        SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                            onTap: () {
                              _showSelectionDialog(context);
                              // _handleImageSelection();
                            },
                            child: Icon(
                              CupertinoIcons.photo_fill,
                              color: Colors.blue,
                            )),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadMoreMessages(),
        tooltip: "Load More Message",
        child: Icon(Icons.arrow_circle_up),
      ),
    );
  }

  void _showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Select Media'),
          content: Text('Choose an option to select media'),
          actions: [
            CupertinoDialogAction(
              child: Text('Image'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _handleImageSelection(); // Call the image selection method
              },
            ),
            CupertinoDialogAction(
              child: Text('Video'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _handleVideoSelection(); // Call the video selection method
              },
            ),
          ],
        );
      },
    );
  }
}

class ChatListScreen extends StatefulWidget {
  final String uiddd;
  final String image;

  ChatListScreen({
    required this.uiddd,
    required this.image,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late TextEditingController _emailController;
  String currentUserDogName = '';
  var currentUserDoc;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot['DogName']}');
        setState(() {
          currentUserDogName = documentSnapshot['DogName'];
        });
      } else {
        print('Document does not exist on the database');
      }
    });
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    // Use transparent background for CircleAvatar
                    backgroundImage: widget.image != null
                        ? NetworkImage(widget.image! as String)
                        : AssetImage('assets/images/3.jpg') as ImageProvider,
                  ),
                  Text(
                    currentUserDogName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  IconButton.filled(
                      onPressed: () {
                        _showAddChatDialog(context);
                      },
                      icon: Icon(
                        CupertinoIcons.add_circled_solid,
                        size: 30,
                        color: Colors.blue,
                      ))

                  // Notifications icon
                ],
              ),
              Divider(),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('AllChats')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No chats available',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    var chats = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        var chat = chats[index];
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatViewScreen(
                                    uid: chat.id,
                                    vuid:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    vname: chat['DogName'],
                                    ptitle: chat['Dog Image'],
                                    prouid: '',
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              elevation: 4.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(chat['Dog Image'] ?? ''),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        chat['DogName'] ?? '',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Enter Email'),
          content: Column(
            children: [
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Enter email',
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('Add'),
              onPressed: () {
                print(_emailController.text);
                _addChat(_emailController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addChat(String email) async {
    print(email);
    FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var userDocument = querySnapshot.docs.first;
        var userUID = userDocument.id;
        userDocument['uid'];
        print(userDocument['uid']);

        String uid = FirebaseAuth.instance.currentUser!.uid;

        FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .collection('AllChats')
            .doc(userUID)
            .set({
          'DogName': userDocument['DogName'],
          'Dog Image': userDocument['Dog Image'],
          // Add other relevant chat information
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chat added successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding chat: $error'),
              duration: Duration(seconds: 2),
            ),
          );
        });

        FirebaseFirestore.instance
            .collection('Users')
            .doc(userUID)
            .collection('AllChats')
            .doc(uid)
            .set({
          'DogName': currentUserDogName,
          'Dog Image': widget.image, //curreunt usedogg image
          // Add other relevant chat information
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chat added successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding chat: $error'),
              duration: Duration(seconds: 2),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not found with the entered email'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching user: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}

class VideoApp extends StatefulWidget {
  const VideoApp({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : CircularProgressIndicator(),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: Row(
                children: [
                  Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
