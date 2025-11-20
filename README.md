# TextureSurprise

A World of Warcraft addon that provides an intuitive interface for WoW players to integrate custom textures into their game interface. Whether you want to add personalized images, custom artwork, or unique visual elements, this addon makes it easy to enhance your UI experience.

### Features

- **Custom Texture Management**: Add, remove, and organize custom textures
- **Edit Mode Integration**: Integrates with WoW's Edit Mode for positioning textures
- **User-Friendly Interface**: Simple and intuitive controls and Minimap button integration for quick access

## Installation

1. Download the latest release from [Releases](../../releases)
2. Extract the `TextureSurprise` folder to your `World of Warcraft\_retail_\Interface\AddOns\` directory
3. Restart World of Warcraft or reload your UI with `/reload`
4. The addon will be available in your AddOns list

## Usage

### Adding Custom Textures

1. Create a folder called `MyCustomTextures` in your `World of Warcraft\_retail_\Interface\AddOns\` directory
2. Place your custom texture files (`.blp` or `.tga` format) in the `MyCustomTextures` folder
3. Launch World of Warcraft and load your character

### Managing Textures

[Screenshot: Main interface]

Access the TextureSurprise menu through the minimap button or command: `/ts`
- **Enter Name**: Add the filename of your texture in the text box
- **Add Texture**: Click the add button to add the given texture
- **Remove Texture**: Click the remove button to remove the given texture

### Editing Textures

[Screenshot: Edit Mode integration]

TextureSurprise integrates with WoW's native Edit Mode, allowing you to:
- Lock/unlock texture positioning
- Adjust texture layer order
- Reset to default positions

### Tutorial Video

[Add video link or embed here]

## Supported Texture Formats

- `.blp` (Blizzard Picture Format)
- `.tga` (Targa Image File)

> **Note**: When converting images from normal image formats, remember to ensure the image has an alpha channel in addition to rgb.

## Changelog

See [Changelog](Changelog.md) for a list of changes in each version.

## Support

If you encounter any issues or have suggestions:
- [Report an issue](../../issues)
- [Submit a feature request](../../issues/new)

## Authors

- alvy023 - *Initial work and development*

## License

This project is licensed under the MIT License - see the [License](License.txt) file for details.

## Third-Party Libraries

TextureSurprise uses several third-party libraries. For complete information about these libraries and their licenses, see [ThirdPartyNotices](ThirdPartyNotices.md).

## Acknowledgments

- Thanks to the WoW addon development community
- Thanks to the Ace3 team for their addon framework
- Thanks to the Plumber team for their icon assets and asset system used in Edit Mode integration
