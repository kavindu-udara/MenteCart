import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/data_sources/auth_remote_data_source.dart';
import 'shared/services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final apiClient = ApiClient();
    final authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
    final authRepository = AuthRepository(
      remoteDataSource: authRemoteDataSource,
    );

    return MaterialApp(
      title: 'MenteCart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => AuthBloc(repository: authRepository),
        child: const LoginPage(),
      ),
    );
  }
}
