import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarea 6',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    HerramientasView(),
    GenderPredictorView(),
    AgePredictorView(),
    UniversityListView(),
    WeatherView(),
    WordPressView(),
    AboutView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenidos a la tarea 6'),
      ),
      drawer: NavigationDrawer(onTap: _onItemTapped),
      body: _views[_selectedIndex],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context); // Cierra el Drawer
    });
  }
}

class NavigationDrawer extends StatelessWidget {
  final Function(int) onTap;

  NavigationDrawer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.build),
            title: Text('Herramientas'),
            onTap: () {
              onTap(0);
            },
          ),
          ListTile(
            leading: Icon(Icons.face),
            title: Text('Predicción de Género'),
            onTap: () {
              onTap(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.accessibility),
            title: Text('Predicción de Edad'),
            onTap: () {
              onTap(2);
            },
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('Universidades'),
            onTap: () {
              onTap(3);
            },
          ),
          ListTile(
            leading: Icon(Icons.wb_sunny),
            title: Text('Clima en RD'),
            onTap: () {
              onTap(4);
            },
          ),
          ListTile(
            leading: Icon(Icons.web),
            title: Text('WordPress'),
            onTap: () {
              onTap(5);
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Acerca de'),
            onTap: () {
              onTap(6);
            },
          ),
        ],
      ),
    );
  }
}

class HerramientasView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/herramientas.jpeg'),
    );
  }
}

class GenderPredictorView extends StatefulWidget {
  @override
  _GenderPredictorViewState createState() => _GenderPredictorViewState();
}

class _GenderPredictorViewState extends State<GenderPredictorView> {
  String? _name;
  String? _gender;

  Future<void> _fetchGender() async {
    final response = await http.get(Uri.parse('https://api.genderize.io/?name=$_name'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _gender = data['gender'];
      });
    } else {
      throw Exception('Failed to load gender');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter a name',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _fetchGender();
            },
            child: Text('Predict Gender'),
          ),
          _gender != null
              ? _gender == 'male'
                  ? Icon(Icons.male, size: 100, color: Colors.blue)
                  : Icon(Icons.female, size: 100, color: Colors.pink)
              : SizedBox(),
        ],
      ),
    );
  }
}

class AgePredictorView extends StatefulWidget {
  @override
  _AgePredictorViewState createState() => _AgePredictorViewState();
}

class _AgePredictorViewState extends State<AgePredictorView> {
  String? _name;
  int? _age;
  String? _ageCategory;

  Future<void> _fetchAge() async {
    final response = await http.get(Uri.parse('https://api.agify.io/?name=$_name'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _age = data['age'];
        if (_age! < 18) {
          _ageCategory = 'Joven';
        } else if (_age! >= 18 && _age! <= 65) {
          _ageCategory = 'Adulto';
        } else {
          _ageCategory = 'Anciano';
        }
      });
    } else {
      throw Exception('Failed to load age');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter a name',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _fetchAge();
            },
            child: Text('Predict Age'),
          ),
          _age != null
              ? Column(
                  children: [
                    Text('Age: $_age'),
                    SizedBox(height: 20),
                    Text('Category: $_ageCategory'),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

class University {
  final String name;
  final List<String> webPages;

  University({required this.name, required this.webPages});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      webPages: List<String>.from(json['web_pages']),
    );
  }
}


// Vista de la lista de universidades
class UniversityListView extends StatefulWidget {
  @override
  _UniversityListViewState createState() => _UniversityListViewState();
}

class _UniversityListViewState extends State<UniversityListView> {
  final TextEditingController _countryController = TextEditingController();
  List<University> _universities = [];

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  // Método para obtener la lista de universidades del país especificado
  Future<void> _fetchUniversities(String country) async {
    try {
      final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=$country'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _universities = data.map((item) => University.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load universities');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Universidades'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Ingrese el nombre del país en inglés',
              ),
              textCapitalization: TextCapitalization.words, // Esta línea permite capitalizar la primera letra de cada palabra
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _fetchUniversities(_countryController.text);
            },
            child: Text('Buscar'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _universities.length,
              itemBuilder: (context, index) {
                final university = _universities[index];
                return ListTile(
                  title: Text(university.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dominio: ${university.webPages.first}'),
                      Text('Link: ${university.webPages.first}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherView extends StatefulWidget {
  @override
  _WeatherViewState createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  String _location = 'Santo Domingo';
  String _description = '';
  String _temperature = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final response = await http.get(Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=$_location&appid=API_KEY&units=metric'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        _description = data['weather'][0]['description'];
        _temperature = data['main']['temp'].toString();
      });
    } else {
      throw Exception('Failed to load weather');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Location: $_location'),
          Text('Description: $_description'),
          Text('Temperature: $_temperature °C87'),
        ],
      ),
    );
  }
}

class WordPressView extends StatefulWidget {
  @override
  _WordPressViewState createState() => _WordPressViewState();
}

class _WordPressViewState extends State<WordPressView> {
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _fetchPosts();
  }

  Future<List<Post>> _fetchPosts() async {
    final response = await http.get(Uri.parse('https://austinkleon.com/wp-json/wp/v2/posts?per_page=3'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WordPress News'),
      ),
      body: Center(
        child: FutureBuilder<List<Post>>(
          future: _posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final List<Post> posts = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Latest Posts:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(posts[index].title),
                          subtitle: Text(posts[index].excerpt),
                          onTap: () {
                            // Navigate to the post page
                            // You can implement navigation logic here
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class Post {
  final String title;
  final String excerpt;

  Post({required this.title, required this.excerpt});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title']['rendered'],
      excerpt: json['excerpt']['rendered'],
    );
  }
}
class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/joel.jpeg'), // Ajusta la ruta de tu imagen
          ),
          SizedBox(height: 20),
          Text(
            'Joel De León Reyes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Matrícula: 20220622',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            'Correo: joeldeleonreyes102@gmail.com',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            'Teléfono: 8297532040',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}