import 'package:flutter/material.dart';

import 'model/product.dart';
import 'model/products_repository.dart';
import 'supplemental/asymmetric_view.dart';
import 'colors.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Inicializa a String vacío para "Todas las marcas" / "Todos los precios"
  String _searchQuery = '';
  String _selectedBrand = ''; 
  String _selectedPriceRange = '';
  List<Product> _filteredProducts = [];
  // Para la barra de búsqueda en la AppBar (que abre el diálogo)
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }
  
  // Función principal para aplicar todos los filtros y actualizar la vista
  void _applyFilters() {
    setState(() {
      // Siempre carga TODOS los productos para empezar el filtrado desde cero
      List<Product> products = ProductsRepository.loadProducts(Category.all);
      
      // 1. Filtrar por búsqueda (busca si el nombre o marca CONTIENE la consulta)
      if (_searchQuery.isNotEmpty) {
        products = products.where((product) =>
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.brand.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }
      
      // 2. Filtrar por marca (si no es '', aplica el filtro)
      if (_selectedBrand.isNotEmpty) {
        products = products.where((product) =>
          product.brand == _selectedBrand
        ).toList();
      }
      
      // 3. Filtrar por rango de precio (si no es '', aplica el filtro)
      if (_selectedPriceRange.isNotEmpty) {
        switch (_selectedPriceRange) {
          case 'low':
            products = products.where((product) => product.price < 50).toList();
            break;
          case 'medium':
            products = products.where((product) => 
              product.price >= 50 && product.price < 100).toList();
            break;
          case 'high':
            products = products.where((product) => product.price >= 100).toList();
            break;
        }
      }
      
      _filteredProducts = products;
    });
  }
  
  // Muestra el diálogo de filtros (Marca y Rango de Precio)
  void _showFilterDialog() {
    // Usamos variables temporales para no actualizar el estado principal antes de "APLICAR"
    String? tempSelectedBrand = _selectedBrand;
    String? tempSelectedPriceRange = _selectedPriceRange;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            
            // Genera la lista de marcas únicas dinámicamente
            final List<DropdownMenuItem<String>> brandItems = [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('Todas las marcas'),
              ),
              ...ProductsRepository.loadProducts(Category.all)
                  .map((product) => product.brand)
                  .toSet() // Obtiene solo las marcas únicas
                  .map((brand) => DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  )),
            ];

            return AlertDialog(
              title: const Text('Filtros'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filtro por marca
                  DropdownButtonFormField<String>(
                    value: tempSelectedBrand == '' ? '' : tempSelectedBrand,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                    items: brandItems,
                    onChanged: (value) {
                      setDialogState(() {
                        tempSelectedBrand = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filtro por rango de precio
                  DropdownButtonFormField<String>(
                    value: tempSelectedPriceRange == '' ? '' : tempSelectedPriceRange,
                    decoration: const InputDecoration(
                      labelText: 'Rango de Precio',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: '', // Usar string vacío para "Todos"
                        child: Text('Todos los precios'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'low',
                        child: Text('Menos de \$50'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'medium',
                        child: Text('\$50 - \$99'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'high',
                        child: Text('\$100 o más'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        tempSelectedPriceRange = value ?? '';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                // Botón LIMPIAR
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempSelectedBrand = '';
                      tempSelectedPriceRange = '';
                    });
                  },
                  child: Text('LIMPIAR', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                ),
                // Botón CANCELAR
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('CANCELAR', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                ),
                // Botón APLICAR
                ElevatedButton(
                  onPressed: () {
                    // Solo actualiza el estado principal y aplica filtros al presionar APLICAR
                    setState(() {
                      _selectedBrand = tempSelectedBrand ?? '';
                      _selectedPriceRange = tempSelectedPriceRange ?? '';
                    });
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 8.0,
                    backgroundColor: kShrineBrown900, 
                    foregroundColor: kShrinePink50,
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                  ),
                  child: const Text('APLICAR'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Muestra el diálogo de Búsqueda
  void _showSearchDialog() {
    String tempSearchQuery = _searchQuery; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Buscar Productos'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: tempSearchQuery),
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre o marca...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              tempSearchQuery = value;
            },
            onSubmitted: (value) {
              // Aplica la búsqueda al presionar Enter/Submit
              setState(() {
                _searchQuery = value;
              });
              _applyFilters();
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Si cancela, pero había texto, lo deja como estaba
              },
              child: Text('CANCELAR', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                // Aplica la búsqueda al presionar BUSCAR
                setState(() {
                  _searchQuery = tempSearchQuery;
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 8.0,
                backgroundColor: kShrineBrown900,
                foregroundColor: kShrinePink50,
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
              ),
              child: const Text('BUSCAR'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHRINE'),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            semanticLabel: 'menu',
          ),
          onPressed: () {
            // El menú de categoría no existe en esta versión
            print('Menu button pressed'); 
          },
        ),
        actions: [
          // Ícono de búsqueda (Lupa)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog, // Abre el diálogo de búsqueda
          ),
          // Ícono de filtros
          IconButton(
            icon: const Icon(Icons.tune), // Usamos Icons.tune que es más común para filtros
            onPressed: _showFilterDialog, 
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Mensaje de "No se encontraron productos"
          if (_filteredProducts.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No se encontraron productos.', 
                    style: TextStyle(fontSize: 18.0, color: kShrineBrown900),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            // Grid de productos (solo si hay productos)
            Expanded(
              child: AsymmetricView(
                products: _filteredProducts, 
              ),
            ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}