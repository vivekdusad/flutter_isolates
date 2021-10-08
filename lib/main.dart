import 'package:flutter/material.dart';
import 'package:isolates_learning/post.dart';

import 'package:isolates_learning/worker.dart';

void main() async {
  Worker worker = Worker();
  await worker.isReady;
  runApp(MyApp(
    worker: worker,
  ));
}

class MyApp extends StatelessWidget {
  final Worker worker;
  const MyApp({
    Key? key,
    required this.worker,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(worker: worker),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Worker worker;
  const MyHomePage({Key? key, required this.worker}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Post>> posts;
  @override
  void initState() {
    posts = widget.worker.fetchPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Isolates Example")),
        body: FutureBuilder<List<Post>>(
          future: posts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                separatorBuilder: (_, __) => const Divider(),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].title ?? ""),
                    subtitle:
                        Text(snapshot.data![index].body ?? "", maxLines: 1),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
