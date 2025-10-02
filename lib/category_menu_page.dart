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
import 'colors.dart';
import 'model/product.dart';

class CategoryMenuPage extends StatelessWidget {
  final Category currentCategory;
  final ValueChanged<Category> onCategoryTap;
  // La lista de categorías incluye todas las opciones que pediste:
  // all, accessories, clothing, home.
  final List<Category> _categories = Category.values;

  const CategoryMenuPage({
    Key? key,
    required this.currentCategory,
    required this.onCategoryTap,
  }) : super(key: key);

  Widget _buildCategory(Category category, BuildContext context) {
    // Convierte el enum a un String legible: Category.all -> ALL
    final categoryString =
        category.toString().replaceAll('Category.', '').toUpperCase();
    final ThemeData theme = Theme.of(context);
    final isSelected = category == currentCategory;

    return GestureDetector(
      // Al tocar, llama a la función de callback para cambiar la categoría en Home.dart
      onTap: () => onCategoryTap(category),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16.0),
            Text(
              categoryString,
              style: theme.textTheme.headlineMedium!.copyWith(
                  // Hace que el texto seleccionado sea más oscuro
                  color: isSelected
                      ? kShrineBrown900
                      : kShrineBrown900.withAlpha(153)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14.0),
            // Muestra la línea rosa debajo de la categoría seleccionada
            if (isSelected)
              Container(
                width: 70.0,
                height: 2.0,
                color: kShrinePink400,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 40.0),
        color: kShrinePink100, // Color de fondo del menú
        child: ListView(
            // Mapea la lista de categorías a widgets
            children: _categories
                .map((Category c) => _buildCategory(c, context))
                .toList()),
      ),
    );
  }
}