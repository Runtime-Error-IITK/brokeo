import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userMetadataStreamProvider;
import 'package:brokeo/frontend/login_pages/login_page3.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataAsync = ref.watch(userMetadataStreamProvider);
    return metadataAsync.when(
      data: (metadata) {
        if (metadata.isEmpty) {
          // Push the metadata page
          return LoginPage3();
        } else {
          // Push the home page
          return HomePage();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text("Error: $error")),
      ),
    );
  }
}

// class AuthPage extends ConsumerStatefulWidget {
//   const AuthPage({super.key});

//   @override
//   AuthPageState createState() => AuthPageState();
// }

// class AuthPageState extends ConsumerState<AuthPage> {
//   @override
//   Widget build(BuildContext context) {
//     final metadataAsync = ref.watch(userMetadataStreamProvider);
//     return metadataAsync.when(
//       data: (metadata) {
//         if (metadata.isEmpty) {
//           // Push the metadata page
//           return MetadataCollectionScreen();
//         } else {
//           // Push the home page
//           return HomeScreen();
//         }
//       },
//       loading: () => const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       ),
//       error: (error, stack) => Scaffold(
//         body: Center(child: Text("Error: $error")),
//       ),
//     );
//   }
// }
