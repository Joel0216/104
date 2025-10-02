// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import 'backdrop.dart'; // Importamos Backdrop para el menú de 3 palitos
import 'category_menu_page.dart'; // Importamos el menú de categorías
import 'model/product.dart';
import 'model/products_repository.dart';
import 'supplemental/asymmetric_view.dart';
import 'colors.dart'; // Importamos kShrineBrown900, kShrinePink50, etc.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Estado Global para Filtrado y Menú de Categorías ---
  Category _currentCategory = Category.all;
  String _searchQuery = ''; // Contiene el texto de la lupa
  String _selectedBrand = ''; // Contiene la marca seleccionada en el filtro
  String _selectedPriceRange = ''; // Contiene el rango de precio seleccionado en el filtro (low, medium, high)
  
  // Lista de productos para la vista
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }
  
  // --- Lógica de Filtrado Principal ---
  void _applyFilters() {
    setState(() {
      // 1. Empezamos con los productos de la categoría seleccionada en el menú de 3 palitos
      List<Product> products = ProductsRepository.loadProducts(_currentCategory);
      
      // 2. Aplicar el filtro de búsqueda (Lupa): busca si el nombre o marca EMPIEZA por la consulta
      if (_searchQuery.isNotEmpty) {
        String query = _searchQuery.toLowerCase();
        products = products.where((product) =>
          product.name.toLowerCase().startsWith(query) ||
          product.brand.toLowerCase().startsWith(query)
        ).toList();
      }
      
      // 3. Aplicar el filtro por marca (Filtro - Marca)
      if (_selectedBrand.isNotEmpty) {
        products = products.where((product) =>
          product.brand == _selectedBrand
        ).toList();
      }
      
      // 4. Aplicar el filtro por rango de precio (Filtro - Rango de Precio)
      if (_selectedPriceRange.isNotEmpty) {
        switch (_selectedPriceRange) {
          case 'low': // Menos de $50
            products = products.where((product) => product.price < 50).toList();
            break;
          case 'medium': // $50 - $99
            products = products.where((product) => 
              product.price >= 50 && product.price < 100).toList();
            break;
          case 'high': // $100 o más
            products = products.where((product) => product.price >= 100).toList();
            break;
        }
      }
      
      _filteredProducts = products;
    });
  }
  
  // --- Funciones para Diálogos ---
  
  // Diálogo de Filtros (Icons.tune)
  void _showFilterDialog() {
    String? tempSelectedBrand = _selectedBrand;
    String? tempSelectedPriceRange = _selectedPriceRange;

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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              // Título: "Filtros"
              title: const Text('Filtros'),
              contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
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
  
  // Diálogo de Búsqueda (Icons.search)
  void _showSearchDialog() {
    String tempSearchQuery = _searchQuery; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Título: "Buscar Productos"
          title: const Text('Buscar Productos'),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          content: TextField(
            autofocus: true,
            // Permite al usuario editar la consulta antes de buscar
            controller: TextEditingController(text: tempSearchQuery), 
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre o marca...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              tempSearchQuery = value; // Captura el texto mientras el usuario escribe
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
              },
              child: Text('CANCELAR', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                // Aplica la búsqueda al presionar BUSCAR
                setState(() {
                  _searchQuery = tempSearchQuery; // Aplica la consulta capturada
                  _applyFilters();
                });
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
  
  // --- Lógica del Menú de 3 Palitos (Backdrop) ---
  
  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
      // Re-aplica filtros al cambiar la categoría principal
      _applyFilters(); 
    });
  }

  Widget _buildFrontLayer() {
    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No se encontraron productos con los filtros aplicados.', 
            style: TextStyle(fontSize: 18.0, color: kShrineBrown900),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return AsymmetricView(
      products: _filteredProducts,
    );
  }

  Widget _buildBackLayer() {
    return CategoryMenuPage(
      currentCategory: _currentCategory,
      onCategoryTap: _onCategoryTap,
    );
  }

  String _currentCategoryTitle(Category category) {
    return category.toString().replaceAll('Category.', '').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Backdrop(
      currentCategory: _currentCategory,
      frontLayer: _buildFrontLayer(),
      backLayer: _buildBackLayer(),
      frontTitle: Text(_currentCategoryTitle(_currentCategory)),
      backTitle: const Text('MENU'),
      // Se pasa la referencia a los métodos para que los IconButtons de Backdrop los llamen.
      onSearchPressed: _showSearchDialog, 
      onFilterPressed: _showFilterDialog,
    );
  }
}