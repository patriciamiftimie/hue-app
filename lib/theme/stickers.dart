import '../model/sticker.dart';

List<Sticker> stickers = [
  Sticker(
    imageUrl: 'images/phase0.png',
    name: 'Sticker 1',
    price: 10,
  ),
  Sticker(
    imageUrl: 'images/phase2.png',
    name: 'Sticker 2',
    price: 15,
  ),
  Sticker(
    imageUrl: 'images/phase5.png',
    name: 'Sticker 3',
    price: 10,
  ),
];

//code for shop

// @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Text(
  //             'Colour Palettes',
  //             style: TextStyle(
  //               fontSize: 24.0,
  //               fontWeight: FontWeight.bold,
  //               color: customPurple,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: colorPalettes.length,
  //             itemBuilder: (context, index) {
  //               final palette = colorPalettes[index];
  //               return buildColorPalette(palette);
  //             },
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Text(
  //             'Stickers',
  //             style: TextStyle(
  //               fontSize: 24.0,
  //               fontWeight: FontWeight.bold,
  //               color: customPurple,
  //             ),
  //           ),
  //         ),
  //         // Add your sticker list view here
  //         // Example:
  //         SizedBox(
  //           height: 200.0, // Adjust the height as needed
  //           child: ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             itemCount: stickersList.length,
  //             itemBuilder: (context, index) {
  //               final sticker = stickersList[index];
  //               return buildSticker(sticker);
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget buildSticker(Sticker sticker) {
  //   return Container(
  //     margin: const EdgeInsets.all(16.0),
  //     padding: const EdgeInsets.all(16.0),
  //     decoration: BoxDecoration(
  //       color: const Color.fromARGB(255, 179, 179, 179),
  //       borderRadius: BorderRadius.circular(10.0),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Image.asset(
  //           sticker.imageUrl,
  //           width: 50, // Adjust the image size as needed
  //           height: 50,
  //         ),
  //         const SizedBox(height: 5.0),
  //         Text(
  //           sticker.name,
  //           style: TextStyle(
  //             fontSize: 14.0,
  //             fontWeight: FontWeight.bold,
  //             color: customWhite,
  //           ),
  //         ),
  //         const SizedBox(height: 5.0),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             SizedBox(
  //               height: 20,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Icon(
  //                     Icons.circle,
  //                     size: 20,
  //                     color: customYellow,
  //                   ),
  //                   Text(
  //                     ' ${sticker.price}',
  //                     style: TextStyle(
  //                       fontSize: 17,
  //                       fontWeight: FontWeight.bold,
  //                       color: customWhite,
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 // Implement purchase logic here
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: customWhite,
  //                 foregroundColor: customPurple,
  //               ),
  //               child: const Text(
  //                 'Buy',
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }