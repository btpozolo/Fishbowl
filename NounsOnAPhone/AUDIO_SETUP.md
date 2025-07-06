# Audio Setup Instructions

## Required Audio Files

To enable sound effects in the Fishbowl game, you need to add two audio files to your Xcode project:

### 1. Background Music
- **File Name**: `clock_tick_old.wav`
- **Purpose**: Ambient background music that plays during active gameplay
- **Format**: WAV (as per your current setup)
- **Duration**: 1-3 minutes (will loop automatically)
- **Volume**: Should be subtle and not distracting from gameplay

### 2. Time-Up Sound Effect
- **File Name**: `final_triple_buzz_mechanical.wav`
- **Purpose**: Alert sound that plays when the timer expires
- **Format**: WAV (as per your current setup)
- **Duration**: 1-3 seconds
- **Volume**: Should be noticeable but not jarring

## How to Add Audio Files

1. **Open your Xcode project**
2. **Right-click on the `NounsOnAPhone` folder** in the project navigator
3. **Select "Add Files to 'NounsOnAPhone'"**
4. **Choose your audio files** (`background_music.mp3` and `time_up.wav`)
5. **Make sure "Add to target" is checked** for your main app target
6. **Click "Add"**

## File Placement

The audio files should be placed directly in the `NounsOnAPhone` folder alongside your Swift files, not in the Assets.xcassets folder.

## Expected File Structure

```
NounsOnAPhone/
├── NounsOnAPhoneApp.swift
├── ContentView.swift
├── GamePlayView.swift
├── GameModels.swift
├── SoundManager.swift
├── SoundSettingsView.swift
├── clock_tick_old.wav           ← Add this file
├── final_triple_buzz_mechanical.wav  ← Add this file
└── Assets.xcassets/
```

## Testing the Audio

Once you've added the audio files:

1. **Build and run the app**
2. **Go to Setup → Sound Settings** to configure audio preferences
3. **Start a game** to hear the background music
4. **Let the timer expire** to hear the time-up sound effect

## Troubleshooting

- **"Background music file not found"**: Make sure `clock_tick_old.wav` is added to the project and target
- **"Time up sound file not found"**: Make sure `final_triple_buzz_mechanical.wav` is added to the project and target
- **No sound playing**: Check that audio is enabled in the sound settings
- **Audio not working on device**: Make sure the device is not on silent mode

## Audio Recommendations

### Background Music
- Use instrumental music without lyrics
- Choose upbeat but not distracting music
- Ensure the file is properly encoded as MP3
- Keep file size reasonable (under 5MB)

### Time-Up Sound
- Use a clear, distinctive alert sound
- Avoid sounds that are too harsh or startling
- Ensure the sound is clearly audible over background music
- Keep duration short (1-3 seconds)

## Customization

You can easily change the audio files by:
1. **Replacing the files** with the same names
2. **Or modifying the SoundManager.swift** file to use different file names 