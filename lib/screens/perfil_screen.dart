import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Layout.dart';
import '../services/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final authService = AuthService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Si ya tenemos los datos del usuario, solo actualizamos el estado
    if (authService.currentUser != null) {
      setState(() {
        isLoading = false;
      });
    } else {
      // De lo contrario, mostramos un mensaje de error
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar les dades de l\'usuari. Si us plau, inicia sessió de nou.'),
            backgroundColor: Colors.red,
          ),
        );
        // Redirigir al login si no hay usuario
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
      }
    }
  }

  void _editarPerfil() {
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No s\'ha pogut carregar l\'usuari'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar un diálogo de edición de perfil
    showDialog(
      context: context,
      builder: (context) => _buildEditarPerfilDialog(context),
    ).then((value) {
      if (value == true) {
        setState(() {}); // Actualizar la UI después de editar
      }
    });
  }

  void _cambiarContrasenya() {
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No s\'ha pogut carregar l\'usuari'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar un diálogo para cambiar la contraseña
    showDialog(
      context: context,
      builder: (context) => _buildCambiarContrasenyaDialog(context),
    ).then((value) {
      if (value == true) {
        setState(() {}); // Actualizar la UI después de cambiar la contraseña
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWrapper(
      title: 'Perfil',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    authService.currentUser?.name ?? 'Usuari',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUser?.email ?? 'email@exemple.com',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            context,
                            Icons.badge,
                            'ID',
                            authService.currentUser?.id ?? 'N/A',
                          ),
                          const Divider(),
                          _buildProfileItem(
                            context, 
                            Icons.cake, 
                            'Edat', 
                            (authService.currentUser?.age ?? 0).toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuració del compte',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                            title: const Text('Editar Perfil'),
                            subtitle: const Text('Actualitza la teva informació personal'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: _editarPerfil,
                          ),
                          ListTile(
                            leading: Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
                            title: const Text('Canviar contrasenya'),
                            subtitle: const Text('Actualitzar la contrasenya'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: _cambiarContrasenya,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        authService.logout();
                        context.go('/login');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al tancar sessió: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('TANCAR SESSIÓ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el diálogo de editar perfil
  Widget _buildEditarPerfilDialog(BuildContext context) {
    final nameController = TextEditingController(text: authService.currentUser?.name);
    final ageController = TextEditingController(text: authService.currentUser?.age.toString());
    final emailController = TextEditingController(text: authService.currentUser?.email);
    final formKey = GlobalKey<FormState>();
    
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cal omplir el nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Edat',
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cal omplir l\'edat';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 0) {
                    return 'Si us plau, insereix una edat vàlida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correu electrònic',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correu electrònic no pot estar buit';
                  }
                  if (!value.contains('@')) {
                    return 'Si us plau insereix una adreça vàlida';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL·LAR'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final userId = authService.currentUser!.id!;
              final success = await authService.updateUser(
                userId,
                nameController.text,
                int.tryParse(ageController.text) ?? 0,
                emailController.text,
              );
              
              if (!context.mounted) return;
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil actualitzat correctament'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al actualitzar el perfil'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context, false);
              }
            }
          },
          child: const Text('GUARDAR'),
        ),
      ],
    );
  }

  // Widget para el diálogo de cambiar contraseña
  Widget _buildCambiarContrasenyaDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool showPassword = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Canviar Contrasenya'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Nova contrasenya',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: !showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contrasenya no pot estar buida';
                      }
                      if (value.length < 6) {
                        return 'La contrasenya ha de tenir almenys 6 caràcters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contrasenya',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: !showPassword,
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Les contrasenyes no coincideixen';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL·LAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final userId = authService.currentUser!.id!;
                  final success = await authService.changePassword(
                    userId,
                    newPasswordController.text,
                  );
                  
                  if (!context.mounted) return;
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contrasenya actualitzada correctament'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al actualitzar la contrasenya'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.pop(context, false);
                  }
                }
              },
              child: const Text('GUARDAR'),
            ),
          ],
        );
      },
    );
  }
}