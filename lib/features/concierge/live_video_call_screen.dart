import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Screen 23: live_concierge_video_call_studio
/// Full-Screen Live HD Consultation Video Studio with CAD Screen Sharing and In-Call Atelier Chat
class LiveVideoCallScreen extends StatefulWidget {
  const LiveVideoCallScreen({super.key});

  @override
  State<LiveVideoCallScreen> createState() => _LiveVideoCallScreenState();
}

class _LiveVideoCallScreenState extends State<LiveVideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isCadShared = true;
  bool _showChat = false;
  final TextEditingController _chatController = TextEditingController();

  final List<Map<String, String>> _messages = [
    {'sender': 'Jean-Luc Atelier', 'text': 'Bonjour Lord Alexander! Reviewing your 3D maxillary arch scan now.'},
    {'sender': 'You', 'text': 'Looking forward to the honeycomb emerald setting.'},
    {'sender': 'Jean-Luc Atelier', 'text': 'Sending over the live CAD mockup to your viewport.'},
  ];

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'You',
          'text': _chatController.text.trim(),
        });
        _chatController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Master Jeweler High-Definition Video Stream
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1200&auto=format&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.darkBase),
            ),
          ),

          // Live CAD Wireframe Floating Screen Share Overlay
          if (_isCadShared)
            Positioned(
              top: 100,
              left: 20,
              child: Container(
                width: 170,
                height: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkBase.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                  boxShadow: const [AppColors.goldGlow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.view_in_ar, size: 12, color: AppColors.primaryGold),
                        SizedBox(width: 4),
                        Text(
                          'LIVE CAD STREAM',
                          style: TextStyle(color: AppColors.primaryGold, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Text(
                        '18K VVS Arch Mesh\nT1-T8 Setting',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyXS(color: Colors.white70),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

          // User Picture-in-Picture Video
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              width: 110,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isVideoOff
                    ? const Center(child: Icon(Icons.videocam_off, color: Colors.white54))
                    : Image.network(
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
                      ),
              ),
            ),
          ),

          // Top Call Status Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryGold),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.rubyRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PLACE VENDÔME LIVE • 14:32',
                          style: AppTypography.labelSM(color: AppColors.primaryGold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showChat ? Icons.chat : Icons.chat_bubble_outline,
                      color: _showChat ? AppColors.primaryGold : Colors.white,
                    ),
                    onPressed: () => setState(() => _showChat = !_showChat),
                  ),
                ],
              ),
            ),
          ),

          // In-Call Chat Drawer (Overlay)
          if (_showChat)
            Positioned(
              left: 20,
              right: 20,
              bottom: 120,
              child: Container(
                height: 240,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkBase.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg['sender'] == 'You';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.primaryGold : AppColors.darkCard,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${msg['sender']}: ${msg['text']}',
                                  style: AppTypography.bodyXS(
                                    color: isMe ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            style: AppTypography.bodyXS(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type message to jeweler...',
                              hintStyle: AppTypography.bodyXS(color: Colors.white54),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primaryGold, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Call Controls Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Button
                    _buildCallControlBtn(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      isActive: _isMuted,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    // Video Toggle Button
                    _buildCallControlBtn(
                      icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                      isActive: _isVideoOff,
                      onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                    ),
                    // CAD Screen Share Toggle
                    _buildCallControlBtn(
                      icon: Icons.screen_share_outlined,
                      isActive: _isCadShared,
                      activeColor: AppColors.primaryGold,
                      onTap: () => setState(() => _isCadShared = !_isCadShared),
                    ),
                    // End Call Button
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.rubyRed,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.call_end, color: Colors.white, size: 26),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControlBtn({
    required IconData icon,
    required bool isActive,
    Color activeColor = AppColors.rubyRed,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white30),
        ),
        child: Icon(
          icon,
          color: isActive ? (activeColor == AppColors.primaryGold ? Colors.black : Colors.white) : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
