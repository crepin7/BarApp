import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projet7/components/build_drop_down.dart';
import 'package:projet7/components/build_text_field.dart';
import 'package:projet7/components/image_picker_widget.dart';
import 'package:projet7/models/bar.dart';
import 'package:projet7/models/boisson.dart';
import 'package:projet7/pages/archive_page.dart';
import 'package:projet7/utils/helpers.dart';
import 'package:projet7/utils/modele.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AjouterBoissonPage extends StatefulWidget {
  Boisson? boisson;
  AjouterBoissonPage({super.key, this.boisson});

  @override
  State<AjouterBoissonPage> createState() => _AjouterBoissonPageState();
}

class _AjouterBoissonPageState extends State<AjouterBoissonPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prixController;
  late TextEditingController _descriptionController;
  late TextEditingController _modeleController;
  late TextEditingController _stockController;
  String? _imagePath;
  late DateTime _dateAjout;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.boisson?.nom);
    _prixController =
        TextEditingController(text: widget.boisson?.prix.last.toString());
    _descriptionController =
        TextEditingController(text: widget.boisson?.description);
    _modeleController =
        TextEditingController(text: getModeleString(widget.boisson?.modele));
    _stockController =
        TextEditingController(text: widget.boisson?.stock.toString());
    _imagePath = widget.boisson?.imagePath;
    _dateAjout = widget.boisson?.dateAjout ?? DateTime.now();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    _modeleController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _ajouterBoisson() {
    if (_formKey.currentState!.validate()) {
      if (_imagePath != null) {
        final monBoisson = Boisson(
          id: widget.boisson?.id ??
              (DateTime.now().millisecondsSinceEpoch % 0xFFFFFFFF),
          nom: _nomController.text.toUpperCase(),
          prix: widget.boisson == null
              ? [double.parse(_prixController.text)]
              : widget.boisson!.prix.last == double.parse(_prixController.text)
                  ? widget.boisson!.prix
                  : [
                      ...widget.boisson!.prix,
                      double.parse(_prixController.text)
                    ],
          description: _descriptionController.text,
          modele: getModele(_modeleController.text),
          stock: int.parse(_stockController.text.padLeft(2, "0")),
          imagePath: _imagePath!,
          dateAjout: _dateAjout,
          dateModification: widget.boisson == null ? null : DateTime.now(),
        );

        context.read<Bar>().ajouterBoisson(monBoisson);

        widget.boisson == null
            ? Navigator.pop(context, "Boisson ajoutée avec succès")
            : Navigator.pop(context, "Boisson Modifiée avec succès");
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Veuillez choisir une image"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text("Ajouter une boisson"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            // Champ Nom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BuildTextField(
                controller: _nomController,
                label: "Nom",
                hint: "Entrez le nom de la boisson",
                icon: Icons.branding_watermark,
              ),
            ),
            const SizedBox(height: 16.0),

            // Champ Modèle (Dropdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BuildDropDown(
                label: "Modèle",
                value: _modeleController.text.isEmpty
                    ? null
                    : _modeleController.text,
                items: const ["Petit", "Grand"],
                icon: Icons.shape_line,
                onChanged: (value) {
                  setState(() {
                    _modeleController.text = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),

            // Champ Prix
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BuildTextField(
                controller: _prixController,
                label: "Prix",
                hint: "Entrez le prix de la boisson",
                icon: Icons.money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ce champ est obligatoire";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16.0),

            // Champ Stock
            BuildTextField(
              controller: _stockController,
              label: "Stock",
              hint: "Entrez la quantité en stock",
              icon: Icons.inventory,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Ce champ est obligatoire";
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Champ Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BuildTextField(
                controller: _descriptionController,
                label: "Description",
                hint: "Entrez une description pour la boisson",
                icon: Icons.description,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 16.0),

            ImagePickerWidget(
              imageFile: _imagePath == null ? null : File(_imagePath!),
              onImageSelected: (String path) {
                setState(() {
                  _imagePath = path;
                });
              },
            ),
            const SizedBox(height: 16.0),
            // Bouton Ajouter
            Center(
              child: ElevatedButton(
                onPressed: _ajouterBoisson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: widget.boisson == null
                    ? const Text(
                        "Ajouter",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      )
                    : const Text(
                        "Modifier",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
