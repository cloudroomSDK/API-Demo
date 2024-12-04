// 麦克风强度（用户的说话声音）
class MicEnergy {
  String userId;
  int newLevel;
  int oldLevel;

  MicEnergy(
      {required this.userId, required this.newLevel, required this.oldLevel});
}
