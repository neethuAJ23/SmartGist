import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';



class FileSelectionModel extends ChangeNotifier {
  List<String> inputPageSelectedFiles = [];
  List<String> referenceMaterialPageSelectedFiles = [];

  //List<String> getInputPageSelectedFiles() {
    //return inputPageSelectedFiles;
  //}

  //List<String> getReferenceMaterialPageSelectedFiles() {
    //return referenceMaterialPageSelectedFiles;
  //}

  void setInputPageSelectedFiles(List<String> files) {
    inputPageSelectedFiles = files;
    print('Input Page Selected Files Updated: $inputPageSelectedFiles');
    notifyListeners();
  }

  void setReferenceMaterialPageSelectedFiles(List<String> files) {
    referenceMaterialPageSelectedFiles = files;
    print('Reference Material Page Selected Files Updated: $referenceMaterialPageSelectedFiles');
    notifyListeners();
  }

  void removeReferenceMaterialPageSelectedFile(int index) {
    referenceMaterialPageSelectedFiles.removeAt(index);
    notifyListeners();
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => FileSelectionModel(), 
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGist',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/signup': (context) => SignUpPage(),
        '/dashboard': (context) => DashboardPage(),
        '/new_project': (context) => NewProjectPage(),
        '/download_pdf': (context) => DownloadPDFPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPasswordVisible = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _emailErrorText = '';
  String _passwordErrorText = '';
  String _loginErrorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Welcome!', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'SmartGist',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Username/Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        errorText: _emailErrorText.isEmpty ? null : _emailErrorText,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        errorText: _passwordErrorText.isEmpty ? null : _passwordErrorText,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      child: ElevatedButton(
                        onPressed: () {
                          _handleLogin();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Login', style: TextStyle(fontSize: 18)),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _loginErrorText,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Signup',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/signup');
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    print('Login button pressed');
    setState(() {
      _emailErrorText = '';
      _passwordErrorText = '';
      _loginErrorText = '';
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailErrorText = 'Enter email';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordErrorText = 'Enter password';
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Login successful');
      Navigator.pushNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      print('Login failed: ${e.message}');
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        setState(() {
          _loginErrorText = 'Invalid email/password';
        });
      } else if (e.code == 'invalid-credential') {
          setState(() {
            _loginErrorText = 'Invalid credentials';
          });
        }
      }
    }
}


class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _errorMessage = '';
  bool _passwordVisible = false; // To toggle password visibility

  Future<void> _createAccount() async {
    setState(() {
      _errorMessage = ''; // Clear any existing error message
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User created: ${userCredential.user}');
      Navigator.pushNamed(context, '/dashboard'); // Navigate to the next screen upon successful sign-up
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _errorMessage = 'Email already in use';
        });
      } else {
        print('Error: ${e.message}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('SIGN UP', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'SmartGist',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Username/Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    child: ElevatedButton(
                      onPressed: _createAccount,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Create Account', style: TextStyle(fontSize: 18)),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/');
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Dashboard',style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/new_project');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('+ New Project', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'New Project',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle input button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InputPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('+ Input', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle reference material button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReferenceMaterialPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('+ Reference Material', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle generate PDF button press
                Navigator.pushNamed(context, '/download_pdf');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Generate PDF', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}


class InputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Input', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Enter topics'),
            ),
            SizedBox(height: 20),
            Text(
              'OR',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickPDF(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('+ PDF', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            Consumer<FileSelectionModel>(
              builder: (context, fileSelectionModel, _) {
                if (fileSelectionModel.inputPageSelectedFiles.isNotEmpty) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Selected File:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Row(
                              children: [
                                Text(fileSelectionModel.inputPageSelectedFiles.first),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => _clearSelectedFile(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Container(); // Placeholder if no file is selected
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearSelectedFile(BuildContext context) {
    Provider.of<FileSelectionModel>(context, listen: false).setInputPageSelectedFiles([]);
  }

  Future<void> _pickPDF(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        // Update the selected files in FileSelectionModel
        Provider.of<FileSelectionModel>(context, listen: false)
            .setInputPageSelectedFiles(
          [result.files.first.name ?? 'Unknown File'],
        );
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }
}


class ReferenceMaterialPage extends StatefulWidget {
  @override
  _ReferenceMaterialPageState createState() => _ReferenceMaterialPageState();
}

class _ReferenceMaterialPageState extends State<ReferenceMaterialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Reference Material',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Link',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'OR',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickPDF(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('+ PDF', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            Consumer<FileSelectionModel>(
              builder: (context, fileSelectionModel, _) {
                if (fileSelectionModel.referenceMaterialPageSelectedFiles.isNotEmpty) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Files Selected:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 5),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: fileSelectionModel.referenceMaterialPageSelectedFiles.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(fileSelectionModel.referenceMaterialPageSelectedFiles[index]),
                              trailing: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () => _removeFile(index, fileSelectionModel),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(); // Placeholder if no file is selected
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPDF(BuildContext context) async {
    try {
      FileSelectionModel fileSelectionModel = Provider.of<FileSelectionModel>(context, listen: false);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        List<String> newFiles = result.files.map((file) => file.name ?? 'Unknown File').toList();
        List<String> selectedFiles = [...fileSelectionModel.referenceMaterialPageSelectedFiles, ...newFiles];
        fileSelectionModel.setReferenceMaterialPageSelectedFiles(selectedFiles);
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  void _removeFile(int index, FileSelectionModel fileSelectionModel) {
    fileSelectionModel.removeReferenceMaterialPageSelectedFile(index);
  }
}





class DownloadPDFPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Download PDF', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Handle Download PDF button press
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Adjust padding for increased size
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Download PDF', style: TextStyle(fontSize: 20)), // Adjust font size for increased size
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              // Logout the current user
              _auth.signOut();
              // Navigate back to the homepage
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.indigo, // Foreground color
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

