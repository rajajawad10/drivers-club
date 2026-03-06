import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'balanced_event_details_page.dart';
import 'add_to_cart_page.dart';
import 'shopping_cart_page.dart';

class ExploreEventsPage extends StatefulWidget {
  const ExploreEventsPage({super.key});

  @override
  State<ExploreEventsPage> createState() => _ExploreEventsPageState();
}

class _ExploreEventsPageState extends State<ExploreEventsPage> {
  String selectedCategory = "All"; // Default to All
  final List<String> categories = ["All", "Party & Drinks", "Food", "Personality", "Private Viewing", "Games", "Action", "Cars Viewing", "Culture", "Family", "Off site"];

  // ── Filter State ────────────────────────────────────────────────────────────
  Set<String> _selectedFilterCategories = {};
  String? _selectedDateFilter; // TODAY, TOMORROW, THIS WEEK, THIS MONTH, NEXT MONTH
  DateTime? _startDate;
  DateTime? _endDate;

  // Filter categories exactly as in image
  final List<String> _filterCategories = [
    "PARTY & DRINKS", "FOOD", "PERSONALITY", "PRIVATE VIEWING",
    "GAMES", "ACTION", "CARS VIEWING", "CULTURE", "FAMILY", "OFF SITE",
  ];

  // Active filter count (for badge on button)
  int get _activeFilterCount =>
      _selectedFilterCategories.length +
          (_selectedDateFilter != null || _startDate != null ? 1 : 0);

  // ── Show Filter Bottom Sheet ────────────────────────────────────────────────
  void _showFilterSheet() {
    // Temp copies so Cancel resets them
    Set<String> tempCats = Set.from(_selectedFilterCategories);
    String? tempDateFilter = _selectedDateFilter;
    DateTime? tempStart = _startDate;
    DateTime? tempEnd = _endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E6E0), // Beige background exactly like image
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Handle bar ──
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
                            ),
                            child: const Icon(LucideIcons.x, size: 18, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Filters",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Filter by categories ──
                          Text(
                            "Filter by categories:",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _filterCategories.map((cat) {
                              final isSelected = tempCats.contains(cat);
                              return GestureDetector(
                                onTap: () => setSheetState(() {
                                  isSelected ? tempCats.remove(cat) : tempCats.add(cat);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.black : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.black : Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : Colors.black,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 32),

                          // ── Filter by date & time ──
                          Text(
                            "Filter by date & time:",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Date range picker
                          Text(
                            "Select dates",
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) => Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(primary: Colors.black),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (range != null) {
                                setSheetState(() {
                                  tempStart = range.start;
                                  tempEnd = range.end;
                                  tempDateFilter = null; // clear chip selection
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    tempStart != null
                                        ? "${tempStart!.day}/${tempStart!.month}/${tempStart!.year}"
                                        : "Start date",
                                    style: GoogleFonts.inter(
                                      color: tempStart != null ? Colors.black : Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Icon(LucideIcons.arrowRight, size: 16, color: Colors.grey),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tempEnd != null
                                          ? "${tempEnd!.day}/${tempEnd!.month}/${tempEnd!.year}"
                                          : "End date",
                                      style: GoogleFonts.inter(
                                        color: tempEnd != null ? Colors.black : Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(LucideIcons.calendarDays, size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Quick date chips
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ["TODAY", "TOMORROW", "THIS WEEK", "THIS MONTH", "NEXT MONTH"]
                                .map((label) {
                              final isSelected = tempDateFilter == label;
                              return GestureDetector(
                                onTap: () => setSheetState(() {
                                  tempDateFilter = isSelected ? null : label;
                                  tempStart = null;
                                  tempEnd = null;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.black : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.black : Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : Colors.black,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // ── Buttons ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
                    child: Column(
                      children: [
                        // CLEAR button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD6D4CE),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setSheetState(() {
                                tempCats.clear();
                                tempDateFilter = null;
                                tempStart = null;
                                tempEnd = null;
                              });
                            },
                            child: Text(
                              "CLEAR",
                              style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // SEARCH button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedFilterCategories = tempCats;
                                _selectedDateFilter = tempDateFilter;
                                _startDate = tempStart;
                                _endDate = tempEnd;
                                // Apply category filter to main list
                                if (_selectedFilterCategories.isNotEmpty) {
                                  selectedCategory = _selectedFilterCategories.first
                                      .split(' ')
                                      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
                                      .join(' ');
                                } else {
                                  selectedCategory = "All";
                                }
                              });
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              "SEARCH",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light professional grey
      appBar: AppBar(
        title: Text(
          "EVENTS",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      showSearch(
                        context: context,
                        delegate: EventSearchDelegate(events: allEvents),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Search events...",
                      hintStyle: GoogleFonts.inter(color: Colors.grey[700]),
                      prefixIcon: Icon(LucideIcons.search, color: Colors.grey[700]),
                      filled: true,
                      fillColor: const Color(0xFFE0E0E0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: _showFilterSheet,
                    child: Row(
                      children: [
                        const Icon(LucideIcons.filter, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "FILTERS${_activeFilterCount > 0 ? '($_activeFilterCount)' : '(0)'}",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E1E2C),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(LucideIcons.shoppingCart, color: Colors.white),
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE45D25),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "1",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 1. HORIZONTAL CATEGORY BAR
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                bool isActive = selectedCategory == categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categories[index];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categories[index],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive ? Colors.black : Colors.grey[500],
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 4,
                            width: 24, // Wider indicator
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                          )
                        else
                          const SizedBox(height: 4), // Placeholder to prevent jumping
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 2. FILTERED EVENTS LIST
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildEventList(),
            ),
          ),

          // 3. FOOTER
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo (Placeholder)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Text("44", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),

                // Social Icon (Placeholder)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.instagram, size: 16, color: Colors.grey),
                ),

                // Links
                Row(
                  children: [
                    Text("FAQ", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    Text("Terms", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    Text("Privacy", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Cart Icon

    );
  }



  // Mock Data
  final List<Map<String, dynamic>> allEvents = [
    {
      "title": "GEOPOLITICAL LUNCH",
      "category": "All",
      "date": "12\nFEB",
      "image": "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800&q=80",
      "tags": ["EVENT"],
      "location": "Club House",
      "time": "12:00 PM",
      "description": "Join us for an exclusive event.",
      "price": "Free"
    },
    {
      "title": "SUMMER ROOFTOP PARTY",
      "category": "All",
      "date": "14\nFEB",
      "image": "https://images.unsplash.com/photo-1514525253440-b393452e8d26?w=800&q=80",
      "tags": ["EVENT"],
      "location": "Club House",
      "time": "12:00 PM",
      "description": "Join us for an exclusive event.",
      "price": "Free"
    },
    {
      "title": "PETROL HOUR",
      "category": "Party & Drinks",
      "date": "19\nFEB",
      "image": "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80",
      "tags": ["PARTY & DRINKS"],
      "location": "CartWalk",
      "time": "Thursday, 6:00 PM",
      "description": "The perfect opportunity to get to know other members in a relaxed setting.",
      "price": "Free"
    },
    {
      "title": "ASH WEDNESDAY",
      "category": "Food",
      "date": "18\nFEB",
      "image": "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800&q=80",
      "tags": ["FOOD"],
      "location": "Restaurant",
      "time": "Wednesday, 8:00 AM",
      "description": "Tradition meets taste: Enjoy a selection of fine fish specialties to mark the beginning of Lent.",
      "price": "Join Us",
      "isButton": true
    },
    {
      "title": "THE GRAND SUNDAY",
      "category": "Food",
      "date": "01\nMAR",
      "image": "https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=800&q=80",
      "tags": ["FAMILY", "FOOD", "EVENTS"],
      "location": "Restaurant",
      "time": "Sunday, 10:00 AM",
      "description": "A relaxed start to the month with an extended breakfast in a cozy club atmosphere.",
      "price": "Free"
    },
    {
      "title": "HUNTERS' REGULARS' TABLE",
      "category": "Personality", // Also Food event but primary category for filter
      "date": "10\nMAR",
      "image": "",
      "key_image": "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80", // fallback for other views
      "headerColor": const Color(0xFF2E5C48),
      "headerIcon": LucideIcons.fan,
      "tags": ["CULTURE", "FOOD", "PERSONALITY"],
      "location": "Club House",
      "time": "Tuesday, 7:00 PM",
      "description": "We invite all hunters to join our regular hunters' table.",
      "price": "Free"
    },
    {
      "title": "BORN IN FLACHT MEETUP",
      "category": "Personality",
      "date": "19\nMAR",
      "image": "",
      "headerColor": const Color(0xFF8E2D6A),
      "headerIcon": LucideIcons.martini,
      "tags": ["PARTY & DRINKS", "CARS VIEWING", "PERSONALITY"],
      "location": "CartWalk",
      "time": "Thursday, 6:00 PM",
      "description": "Porsche GT dinner organized by our member Hans-Jörg Lenz.",
      "price": "Free"
    },
    {
      "title": "WOMEN WITH DRIVE BREAKFAST",
      "category": "Personality",
      "date": "20\nMAR",
      "image": "",
      "headerColor": const Color(0xFF1B6A7A),
      "headerIcon": LucideIcons.messageCircle,
      "tags": ["FOOD", "PERSONALITY"],
      "location": "Club House",
      "time": "Friday, 9:00 AM",
      "description": "With Monika Drexel on the topic \"Smart Supplements!\"",
      "price": "from €32.77"
    },
    {
      "title": "GAMES EVENING",
      "category": "Games",
      "date": "24\nFEB",
      "image": "",
      "headerColor": const Color(0xFF6A2B81), // Purple
      "headerIcon": LucideIcons.dices, // Assuming dice exists, otherwise circle or box
      "tags": ["GAMES"],
      "location": "Club House",
      "time": "Tuesday, 7:00 PM",
      "description": "Every last Tuesday of the month, we invite you to enjoy billiards, darts and table football in the Games Room.",
      "price": "Free",
      "ticketStatus": "18 tickets left"
    },
    {
      "title": "GAMES EVENING",
      "category": "Games",
      "date": "24\nMAR",
      "image": "",
      "headerColor": const Color(0xFF6A2B81),
      "headerIcon": LucideIcons.dices,
      "tags": ["GAMES"],
      "location": "Club House",
      "time": "Tuesday, 7:00 PM",
      "description": "Every last Tuesday of the month, we invite you to enjoy billiards, darts and table football in the Games Room.",
      "price": "Free",
      "ticketStatus": "Tickets Available"
    },
    {
      "title": "GAMES EVENING",
      "category": "Games",
      "date": "28\nAPR",
      "image": "",
      "headerColor": const Color(0xFF6A2B81),
      "headerIcon": LucideIcons.dices,
      "tags": ["GAMES"],
      "location": "Club House",
      "time": "Tuesday, 7:00 PM",
      "description": "Every last Tuesday of the month, we invite you to enjoy billiards, darts and table football in the Games Room.",
      "price": "Free",
      "ticketStatus": "25 tickets left"
    },
    // ACTION EVENTS
    {
      "title": "DBCM MOVIE NIGHT AT THE CLUB CINEMA",
      "category": "Action",
      "date": "02\nMAR",
      "image": "",
      "headerColor": const Color(0xFF616161), // Dark Slate Grey
      "headerIcon": LucideIcons.clapperboard,
      "tags": ["ACTION", "CULTURE"],
      "location": "Kino",
      "time": "Monday, 8:15 PM",
      "description": "Movie: Talladega Nights: The Ballad of Ricky Bobby",
      "price": "Free",
      "ticketStatus": "15 tickets left"
    },
    {
      "title": "DBCM MOVIE NIGHT AT THE CLUB CINEMA",
      "category": "Action",
      "date": "13\nAPR",
      "image": "",
      "headerColor": const Color(0xFF616161),
      "headerIcon": LucideIcons.clapperboard,
      "tags": ["ACTION", "CULTURE"],
      "location": "Kino",
      "time": "Monday, 8:15 PM",
      "description": "Movie: Ronin",
      "price": "Free",
      "ticketStatus": "15 tickets left"
    },
    {
      "title": "MYLE FESTIVAL ZURICH",
      "category": "Action",
      "date": "25\nAPR",
      "image": "",
      "headerColor": const Color(0xFF8B7E55), // Tan/Olive
      "headerIcon": LucideIcons.car,
      "tags": ["ACTION", "CARS VIEWING"],
      "location": "MOTORWORLD Manufaktur Region Zurich",
      "time": "Saturday, 8:00 AM",
      "description": "Visit the legendary MYLE Festival at MOTORWORLD Manufaktur Region Zurich this year.",
      "price": "Join Us",
      "isButton": true
    },
    {
      "title": "DBCM MOVIE NIGHT AT THE CLUB CINEMA",
      "category": "Action",
      "date": "04\nMAY",
      "image": "",
      "headerColor": const Color(0xFF616161),
      "headerIcon": LucideIcons.clapperboard,
      "tags": ["ACTION", "CULTURE"],
      "location": "Kino",
      "time": "Monday, 8:15 PM",
      "description": "Movie: The Italian Job",
      "price": "Free",
      "ticketStatus": "15 tickets left"
    },
    {
      "title": "DBCM MOVIE NIGHT AT THE CLUB CINEMA",
      "category": "Action",
      "date": "01\nJUN",
      "image": "",
      "headerColor": const Color(0xFF616161),
      "headerIcon": LucideIcons.clapperboard,
      "tags": ["ACTION", "CULTURE"],
      "location": "Kino",
      "time": "Monday, 8:15 PM",
      "description": "Movie: Le Mans",
      "price": "Free",
      "ticketStatus": "15 tickets left"
    },
    {
      "title": "MYLE FESTIVAL MUNICH",
      "category": "Action",
      "date": "12\nJUN",
      "image": "",
      "headerColor": const Color(0xFF8B7E55),
      "headerIcon": LucideIcons.car,
      "tags": ["ACTION", "CARS VIEWING"],
      "location": "MOTORWORLD Munich",
      "time": "Friday, 9:00 AM",
      "description": "On the MOTORWORLD grounds and in our Park Ferme, you can see rare supercars and boats with interesting talks and culinary highlights.",
      "price": "Join Us",
      "isButton": true
    },
    // CARS VIEWING EVENTS
    {
      "title": "SEASON OPENING",
      "category": "Cars Viewing",
      "date": "19\nAPR",
      "image": "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80", // Classic Car
      "headerColor": const Color(0xFF8B7E55),
      "headerIcon": LucideIcons.car,
      "tags": ["CARS VIEWING", "FAMILY", "FOOD"],
      "location": "Club House",
      "time": "Sunday, 10:00 AM",
      "description": "Look forward to an extensive breakfast buffet with kids' entertainment - and, of course, your freshly spring-prepared vintage car.",
      "price": "Free",
      "ticketStatus": "Tickets Available"
    },
    {
      "title": "GERMAN CLASSIC NIGHT AT THE CLUB",
      "category": "Cars Viewing",
      "date": "22\nAPR",
      "image": "",
      "headerColor": const Color(0xFF8B7E55),
      "headerIcon": LucideIcons.car, // Using car as carFront is not available
      "tags": ["PARTY & DRINKS", "CARS VIEWING", "FOOD"],
      "location": "CartWalk",
      "time": "Wednesday, 6:30 PM",
      "description": "German classics from Porsche, BMW and Mercedes meet German culinary specialties.",
      "price": "Free",
      "ticketStatus": "Tickets Available"
    },
    // CULTURE EVENTS
    {
      "title": "CIGAR TASTING",
      "category": "Culture",
      "date": "24\nFEB",
      "image": "https://images.unsplash.com/photo-1527120245119-59da4216301d?w=800",
      "tags": ["CULTURE"],
      "location": "Havanna Lounge",
      "time": "Tuesday, 8:00 PM",
      "description": "Experience fine cigars, exciting aromas, and expert knowledge in refined company.",
      "price": "Free",
      "ticketStatus": "Sold Out"
    },
    {
      "title": "PETROL TALK",
      "category": "Culture",
      "date": "26\nFEB",
      "image": "",
      "headerColor": const Color(0xFF1B6A7A), // Teal
      "headerIcon": LucideIcons.messageCircle,
      "tags": ["CULTURE", "EVENTS"],
      "location": "Bibliothek",
      "time": "Thursday, 7:00 PM",
      "description": "Full speed ahead – Drivers and teams battle for glory and a place in history in the NASCAR Cup.",
      "price": "Free",
      "ticketStatus": "Tickets Available"
    },
    {
      "title": "DBCM MOVIE NIGHT AT THE CLUB CINEMA",
      "category": "Culture",
      "date": "02\nMAR",
      "image": "",
      "headerColor": const Color(0xFF616161),
      "headerIcon": LucideIcons.clapperboard,
      "tags": ["ACTION", "CULTURE"],
      "location": "Kino",
      "time": "Monday, 8:15 PM",
      "description": "Movie: Talladega Nights: The Ballad of Ricky Bobby",
      "price": "Free",
      "ticketStatus": "15 tickets left"
    },
    {
      "title": "F1 SUNDAY",
      "category": "Culture",
      "date": "08\nMAR",
      "image": "",
      "headerColor": const Color(0xFF006494), // Blue
      "headerIcon": LucideIcons.users,
      "tags": ["CULTURE", "EVENTS", "FAMILY"],
      "location": "Restaurant",
      "time": "Sunday, 10:00 AM",
      "description": "Enjoy relaxed hours – from breakfast to dinner. Australian GP (rerun) – the start of the 2026 Formula 1 season.",
      "price": "Join Us",
      "isButton": true
    },
    {
      "title": "HUNTERS' REGULARS' TABLE",
      "category": "Culture",
      "date": "10\nMAR",
      "image": "",
      "headerColor": const Color(0xFF2E5C48),
      "headerIcon": LucideIcons.fan,
      "tags": ["CULTURE", "FOOD", "PERSONALITY"],
      "location": "Club House",
      "time": "Tuesday, 7:00 PM",
      "description": "We invite all hunters to join our regular hunters' table.",
      "price": "Free"
    },
    {
      "title": "PETROL TALK",
      "category": "Culture",
      "date": "12\nMAR",
      "image": "",
      "headerColor": const Color(0xFF1B6A7A),
      "headerIcon": LucideIcons.messageCircle,
      "tags": ["CULTURE", "EVENTS"],
      "location": "Bibliothek",
      "time": "Thursday, 7:00 PM",
      "description": "Vanished car brands – Why they disappeared and what happened to them!",
      "price": "Free",
      "ticketStatus": "Tickets Available"
    },
    {
      "title": "F1 SUNDAY",
      "category": "Culture",
      "date": "15\nMAR",
      "image": "",
      "headerColor": const Color(0xFF006494), // Blue
      "headerIcon": LucideIcons.users,
      "tags": ["CULTURE", "EVENTS", "FAMILY"],
      "location": "Restaurant",
      "time": "Sunday, 10:00 AM",
      "description": "Enjoy relaxed hours – from breakfast to dinner. Saudi Arabian GP (rerun).",
      "price": "Join Us",
      "isButton": true
    },
    {
      "title": "PETROL TALK",
      "category": "Culture",
      "date": "26\nMAR",
      "image": "",
      "headerColor": const Color(0xFF1B6A7A),
      "headerIcon": LucideIcons.messageCircle,
      "tags": ["CULTURE", "EVENTS"],
      "location": "Bibliothek",
      "time": "Thursday, 7:00 PM",
      "description": "Discussion on the future of synthetic fuels.",
      "price": "Free",
      "ticketStatus": "Tickets Available"
    },
    // FAMILY EVENTS
    {
      "title": "THE GRAND SUNDAY",
      "category": "Family",
      "date": "01\nMAR",
      "image": "",
      "headerColor": const Color(0xFF0066B2),
      "headerIcon": LucideIcons.users,
      "tags": ["FAMILY", "FOOD", "EVENTS"],
      "location": "Restaurant",
      "time": "Sunday, 10:00 AM",
      "description": "A relaxed start to the month with an extended breakfast in a cozy club atmosphere.",
      "price": "Join Us",
      "isButton": true,
      "hasFoodBadge": true
    },
    {
      "title": "F1 SUNDAY",
      "category": "Family",
      "date": "08\nMAR",
      "image": "",
      "headerColor": const Color(0xFF0066B2),
      "headerIcon": LucideIcons.users,
      "tags": ["CULTURE", "EVENTS", "FAMILY"],
      "location": "Restaurant",
      "time": "Sunday, 10:00 AM",
      "description": "Enjoy relaxed hours – from breakfast to dinner. Australian GP (rerun) – the start of the 2026 Formula 1 season.",
      "price": "Join Us",
      "isButton": true
    },
  ];

  Widget _buildEventList() {
    // 1. Filter Logic
    final filteredList = selectedCategory == "All"
        ? allEvents
        : allEvents.where((e) {
      // Check main category or if tags contain the category (for overlap)
      final cat = e["category"] as String;
      final tags = e["tags"] as List<String>;
      // Simple logic: Exact match on category OR tag match
      return cat == selectedCategory || tags.contains(selectedCategory.toUpperCase());
    }).toList();

    // 2. Empty State
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.filterX, size: 60, color: Colors.grey[300]), // Filter icon
            const SizedBox(height: 20),
            Text(
              "Your filters produced no results!",
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1E2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting or clearing your filters to display better results.",
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    // 3. List Builder
    return ListView.builder(
      key: ValueKey(selectedCategory), // Key for animation
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final event = filteredList[index];
        return _EventCard(
          title: event["title"],
          tag: (event["tags"] as List<String>).first,
          additionalTags: (event["tags"] as List<String>).sublist(1),
          date: event["date"],
          image: event["image"] ?? "",
          headerColor: event["headerColor"],
          headerIcon: event["headerIcon"],
          index: index,
          location: event["location"],
          time: event["time"],
          description: event["description"],
          price: event["price"] ?? "Free",
          isButton: event["isButton"] ?? false,
          ticketStatus: event["ticketStatus"] ?? "Tickets Available",
          hasFoodBadge: event["hasFoodBadge"] ?? false,
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String tag;
  final List<String> additionalTags;
  final String date;
  final String image;
  final int index;
  final String location;
  final String time;
  final String description;
  final Color? headerColor;
  final IconData? headerIcon;
  final String price;
  final bool isButton;
  final String ticketStatus;
  final bool hasFoodBadge;

  const _EventCard({
    required this.title,
    required this.tag,
    this.additionalTags = const [],
    required this.date,
    required this.image,
    required this.index,
    required this.location,
    required this.time,
    required this.description,
    this.headerColor,
    this.headerIcon,
    this.price = "Free",
    this.isButton = false,
    this.ticketStatus = "Tickets Available", // Default
    this.hasFoodBadge = false,
  });

  double _parsePrice(String priceString) {
    if (priceString.toLowerCase().contains("free")) return 0.0;
    final cleaned = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BalancedEventDetailsPage(
            eventName: title,
            category: tag,
            description: description,
            date: date.replaceAll('\n', ' '),
            time: time,
            location: location,
            image: image,
            price: _parsePrice(price),
          )),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4), // Minimalist square rounded styling
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or Colored Header with Date Overlay
            Stack(
              children: [
                if (image.isNotEmpty)
                  Image.network(
                    image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(LucideIcons.image, size: 50, color: Colors.grey),
                      );
                    },
                  )
                else
                  Container(
                    height: 220,
                    width: double.infinity,
                    color: headerColor ?? Colors.grey,
                    child: Center(
                      child: Icon(headerIcon ?? LucideIcons.star, size: 80, color: Colors.white),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color(0xFF1E1E2C), // Dark overlay for date
                    child: Text(
                      date,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1E2C),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(tag),
                      ...additionalTags.map((t) => _buildTag(t)).toList(),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Details Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          time,
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Bottom Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.tag, size: 14, color: isButton ? const Color(0xFFE45D25) : Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            price,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isButton ? FontWeight.bold : FontWeight.w500,
                              color: isButton ? const Color(0xFFE45D25) : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ticketStatus,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFE45D25), // Brand Red/Orange
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class EventSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> events;

  EventSearchDelegate({required this.events});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFFFFCC00), // PitStop Yellow
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear, color: Colors.black), onPressed: () => query = "")
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) {

    if (query.trim().isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.search, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Type to search events...',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final queryLower = query.toLowerCase().trim();
    final results = events.where((e) {
      final title = e['title'].toString().toLowerCase();
      final tags  = (e['tags'] as List<dynamic>).join(' ').toLowerCase();
      final loc   = e['location'].toString().toLowerCase();
      return title.contains(queryLower) ||
          tags.contains(queryLower)  ||
          loc.contains(queryLower);
    }).toList();

    if (results.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.searchX, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No events found for "$query"',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final event = results[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
                event['title'],
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)
            ),
            subtitle: Text(
              '${event['date'].toString().replaceAll('\n', ' ')}  ·  ${event['location']}',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: (event['image'] != null && event['image'].toString().isNotEmpty)
                  ? NetworkImage(event['image'])
                  : null,
              child: (event['image'] == null || event['image'].toString().isEmpty)
                  ? const Icon(LucideIcons.calendar, color: Colors.black54)
                  : null,
            ),
            onTap: () {
              close(context, null);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BalancedEventDetailsPage(
                  eventName: event['title'],
                  category: (event['tags'] as List).firstOrNull ?? "Event",
                  description: event['description'],
                  date: event['date'].toString().replaceAll('\n', ' '),
                  time: event['time'],
                  location: event['location'],
                  image: event['image'] ?? "",
                  price: _parsePrice(event['price'].toString()),
                )),
              );
            },
          );
        },
      ),
    );
  }


  double _parsePrice(String priceString) {
    if (priceString.toLowerCase().contains("free")) return 0.0;
    final cleaned = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
