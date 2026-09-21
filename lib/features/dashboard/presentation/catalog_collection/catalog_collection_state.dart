import 'package:equatable/equatable.dart';

import '../../../games/domain/models/catalog_collection.dart';
import '../../../library/domain/models/library_status.dart';

final class CatalogCollectionState extends Equatable {
  const CatalogCollectionState({
    required this.title,
    this.sections = const [],
    this.selectedId,
    this.layout = LibraryLayout.grid,
    this.loading = false,
    this.error,
  });

  final String title;
  final List<CatalogSection> sections;
  final String? selectedId;
  final LibraryLayout layout;
  final bool loading;
  final String? error;

  CatalogSection? get selected {
    for (final section in sections) {
      if (section.id == selectedId) {
        return section;
      }
    }
    return sections.isEmpty ? null : sections.first;
  }

  CatalogCollectionState copyWith({
    String? title,
    List<CatalogSection>? sections,
    String? selectedId,
    LibraryLayout? layout,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return CatalogCollectionState(
      title: title ?? this.title,
      sections: sections ?? this.sections,
      selectedId: selectedId ?? this.selectedId,
      layout: layout ?? this.layout,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    title,
    sections,
    selectedId,
    layout,
    loading,
    error,
  ];
}
