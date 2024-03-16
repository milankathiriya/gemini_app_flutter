import 'dart:convert';
import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchFieldController = TextEditingController();

  List<Map<String, dynamic>> responses = [];
  bool isLoading = false;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    searchFieldController.addListener(() {
      setState(() {
        isButtonEnabled = searchFieldController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini App"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 14,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: responses.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Q. ${responses[i]['question']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              Text("Ans:\n${responses[i]['answer']}"),
                            ],
                          )),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: searchFieldController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter your prompt here...",
                      ),
                      onChanged: (val) {},
                    ),
                  ),
                  (isLoading)
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: (isButtonEnabled == false)
                              ? null
                              : () async {
                                  String apiKey =
                                      "PUT_YOUR_API_KEY_HERE";

                                  final model = GenerativeModel(
                                      model: 'gemini-pro', apiKey: apiKey);

                                  final prompt = searchFieldController.text;
                                  final content = [Content.text(prompt)];
                                  setState(() {
                                    isLoading = true;
                                  });
                                  final response =
                                      await model.generateContent(content);

                                  setState(() {
                                    isLoading = false;
                                  });
                                  log("${response.text}");

                                  if (response.text != null) {
                                    setState(() {
                                      responses.add({
                                        "question": prompt,
                                        "answer": response.text,
                                      });
                                    });
                                    searchFieldController.clear();
                                  }
                                },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
