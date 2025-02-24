class DialysisStatisticDataModel {
  final int totalHospital;
  final int dialysisUnit;
  final int totalMachine;
  final int activeMachine;
  final int damagedMachine;
  final int operationalDialysisBed;
  final int totalNephrologist;
  final int totalMdgp;
  final int totalMedicalOfficer;
  final int totalStaffNurse;
  final int totalBiomedicalTechnician;
  final int totalHelper;
  final int trainedMdgp;
  final int trainedMedicalOfficer;
  final int trainedStaffNurse;
  final int trainedBiomedicalTechnician;
  final int trainedHelper;
  final int waitingPatient;
  final int activePatient;
  final int registeredPatient;

  DialysisStatisticDataModel({
    required this.totalHospital,
    required this.dialysisUnit,
    required this.totalMachine,
    required this.activeMachine,
    required this.damagedMachine,
    required this.operationalDialysisBed,
    required this.totalNephrologist,
    required this.totalMdgp,
    required this.totalMedicalOfficer,
    required this.totalStaffNurse,
    required this.totalBiomedicalTechnician,
    required this.totalHelper,
    required this.trainedMdgp,
    required this.trainedMedicalOfficer,
    required this.trainedStaffNurse,
    required this.trainedBiomedicalTechnician,
    required this.trainedHelper,
    required this.waitingPatient,
    required this.activePatient,
    required this.registeredPatient,
  });

  factory DialysisStatisticDataModel.fromJson(Map<String, dynamic> json) {
    return DialysisStatisticDataModel(
      totalHospital: json['total_hospital'],
      dialysisUnit: json['dialysis_unit'],
      totalMachine: json['total_machine'],
      activeMachine: json['active_machine'],
      damagedMachine: json['damaged_machine'],
      operationalDialysisBed: json['operational_dialysis_bed'],
      totalNephrologist: json['total_nephrologist'],
      totalMdgp: json['total_mdgp'],
      totalMedicalOfficer: json['total_medical_officer'],
      totalStaffNurse: json['total_staff_nurse'],
      totalBiomedicalTechnician: json['total_biomedical_technician'],
      totalHelper: json['total_helper'],
      trainedMdgp: json['trained_mdgp'],
      trainedMedicalOfficer: json['trained_medical_officer'],
      trainedStaffNurse: json['trained_staff_nurse'],
      trainedBiomedicalTechnician: json['trained_biomedical_technician'],
      trainedHelper: json['trained_helper'],
      waitingPatient: json['waiting_patient'],
      activePatient: json['active_patient'],
      registeredPatient: json['registered_patient'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_hospital': totalHospital,
      'dialysis_unit': dialysisUnit,
      'total_machine': totalMachine,
      'active_machine': activeMachine,
      'damaged_machine': damagedMachine,
      'operational_dialysis_bed': operationalDialysisBed,
      'total_nephrologist': totalNephrologist,
      'total_mdgp': totalMdgp,
      'total_medical_officer': totalMedicalOfficer,
      'total_staff_nurse': totalStaffNurse,
      'total_biomedical_technician': totalBiomedicalTechnician,
      'total_helper': totalHelper,
      'trained_mdgp': trainedMdgp,
      'trained_medical_officer': trainedMedicalOfficer,
      'trained_staff_nurse': trainedStaffNurse,
      'trained_biomedical_technician': trainedBiomedicalTechnician,
      'trained_helper': trainedHelper,
      'waiting_patient': waitingPatient,
      'active_patient': activePatient,
      'registered_patient': registeredPatient,
    };
  }
}