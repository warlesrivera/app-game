import '../../library/domain/models/library_status.dart';
import '../../library/presentation/library_page.dart';

class WishlistPage extends LibraryPage {
  const WishlistPage({super.key})
    : super(pinnedFilter: LibraryFilter.wishlist, title: 'Deseos');
}
