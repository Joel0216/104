import 'package:flutter/material.dart';

import 'model/product.dart';
import 'model/products_repository.dart';
import 'supplemental/asymmetric_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  String? _selectedBrand;
  String? _selectedPriceRange;
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = ProductsRepository.loadProducts(Category.all);
  }

  void _applyFilters() {
    setState(() {
      List<Product> products = ProductsRepository.loadProducts(Category.all);
      
      // Filtrar por búsqueda
      if (_searchQuery.isNotEmpty) {
        products = products.where((product) =>
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.brand.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }
      
      // Filtrar por marca
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        products = products.where((product) =>
          product.brand == _selectedBrand
        ).toList();
      }
      
      // Filtrar por rango de precio
      if (_selectedPriceRange != null && _selectedPriceRange!.isNotEmpty) {
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filtros'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filtro por marca
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('Todas las marcas'),
                      ),
                      ...ProductsRepository.loadProducts(Category.all)
                          .map((product) => product.brand)
                          .toSet()
                          .map((brand) => DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedBrand = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filtro por rango de precio
                  DropdownButtonFormField<String>(
                    value: _selectedPriceRange,
                    decoration: const InputDecoration(
                      labelText: 'Rango de Precio',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: '',
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
                        _selectedPriceRange = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _selectedBrand = '';
                      _selectedPriceRange = '';
                    });
                  },
                  child: const Text('Limpiar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHRINE'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Ícono de búsqueda
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Buscar Productos'),
                    content: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o marca...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _applyFilters();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Buscar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Ícono de filtros
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          // Mostrar filtros activos
          if (_selectedBrand != null && _selectedBrand!.isNotEmpty ||
              _selectedPriceRange != null && _selectedPriceRange!.isNotEmpty ||
              _searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${_filteredProducts.length} productos'),
                backgroundColor: Colors.white,
                onDeleted: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedBrand = null;
                    _selectedPriceRange = null;
                  });
                  _applyFilters();
                },
                deleteIcon: const Icon(Icons.clear, size: 18),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda rápida
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  _applyFilters();
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ),
          // Grid de productos
          Expanded(
            child: AsymmetricView(
              products: ProductsRepository.loadProducts(Category.all),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}