import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/providers/patient_provider.dart';
import 'package:flutter_app/models/index.dart';

@GenerateMocks([ApiService])
import 'patient_provider_test.mocks.dart';

void main() {
  late PatientProvider patientProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    patientProvider = PatientProvider(mockApiService);
  });

  Patient createTestPatient({int id = 1, String nom = 'Dupont'}) {
    return Patient(
      id: id,
      nom: nom,
      prenom: 'Jean',
      email: 'jean.dupont@test.com',
      dateNaissance: '1990-05-15',
      numeroSecuriteSociale: '1900512345678',
      sexe: 'M',
    );
  }

  group('PatientProvider', () {
    group('loadPatients', () {
      test('should load patients successfully', () async {
        // Arrange
        final patients = [createTestPatient(id: 1), createTestPatient(id: 2)];
        when(mockApiService.getPatients()).thenAnswer((_) async => patients);

        // Act
        await patientProvider.loadPatients();

        // Assert
        expect(patientProvider.patients.length, 2);
        expect(patientProvider.error, isNull);
        expect(patientProvider.isLoading, false);
        verify(mockApiService.getPatients()).called(1);
      });

      test('should set error on failed load', () async {
        // Arrange
        when(mockApiService.getPatients()).thenThrow(Exception('Network error'));

        // Act
        await patientProvider.loadPatients();

        // Assert
        expect(patientProvider.patients, isEmpty);
        expect(patientProvider.error, contains('Network error'));
        expect(patientProvider.isLoading, false);
      });
    });

    group('loadPatient', () {
      test('should load single patient successfully', () async {
        // Arrange
        final patient = createTestPatient();
        when(mockApiService.getPatient(1)).thenAnswer((_) async => patient);

        // Act
        await patientProvider.loadPatient(1);

        // Assert
        expect(patientProvider.selectedPatient, patient);
        expect(patientProvider.error, isNull);
        verify(mockApiService.getPatient(1)).called(1);
      });

      test('should set error on failed load', () async {
        // Arrange
        when(mockApiService.getPatient(1)).thenThrow(Exception('Not found'));

        // Act
        await patientProvider.loadPatient(1);

        // Assert
        expect(patientProvider.selectedPatient, isNull);
        expect(patientProvider.error, contains('Not found'));
      });
    });

    group('createPatient', () {
      test('should create patient successfully', () async {
        // Arrange
        final patient = createTestPatient();
        when(mockApiService.createPatient(any)).thenAnswer((_) async => patient);

        // Act
        final result = await patientProvider.createPatient(patient);

        // Assert
        expect(result, true);
        expect(patientProvider.patients.length, 1);
        expect(patientProvider.error, isNull);
        verify(mockApiService.createPatient(any)).called(1);
      });

      test('should return false on failed create', () async {
        // Arrange
        final patient = createTestPatient();
        when(mockApiService.createPatient(any)).thenThrow(Exception('Validation error'));

        // Act
        final result = await patientProvider.createPatient(patient);

        // Assert
        expect(result, false);
        expect(patientProvider.error, contains('Validation error'));
      });
    });

    group('updatePatient', () {
      test('should update patient successfully', () async {
        // Arrange
        final patient = createTestPatient();
        final updatedPatient = createTestPatient(nom: 'Updated');
        
        when(mockApiService.getPatients()).thenAnswer((_) async => [patient]);
        when(mockApiService.updatePatient(1, any)).thenAnswer((_) async => updatedPatient);

        await patientProvider.loadPatients();

        // Act
        final result = await patientProvider.updatePatient(1, updatedPatient);

        // Assert
        expect(result, true);
        expect(patientProvider.selectedPatient?.nom, 'Updated');
        verify(mockApiService.updatePatient(1, any)).called(1);
      });

      test('should return false on failed update', () async {
        // Arrange
        final patient = createTestPatient();
        when(mockApiService.updatePatient(1, any)).thenThrow(Exception('Update failed'));

        // Act
        final result = await patientProvider.updatePatient(1, patient);

        // Assert
        expect(result, false);
        expect(patientProvider.error, contains('Update failed'));
      });
    });

    group('deletePatient', () {
      test('should delete patient successfully', () async {
        // Arrange
        final patient = createTestPatient();
        when(mockApiService.getPatients()).thenAnswer((_) async => [patient]);
        when(mockApiService.deletePatient(1)).thenAnswer((_) async => {});

        await patientProvider.loadPatients();
        expect(patientProvider.patients.length, 1);

        // Act
        final result = await patientProvider.deletePatient(1);

        // Assert
        expect(result, true);
        expect(patientProvider.patients, isEmpty);
        verify(mockApiService.deletePatient(1)).called(1);
      });

      test('should return false on failed delete', () async {
        // Arrange
        when(mockApiService.deletePatient(1)).thenThrow(Exception('Delete failed'));

        // Act
        final result = await patientProvider.deletePatient(1);

        // Assert
        expect(result, false);
        expect(patientProvider.error, contains('Delete failed'));
      });
    });

    group('clearSelection', () {
      test('should clear selected patient', () async {
        // Arrange
        final patient = createTestPatient();
        when(mockApiService.getPatient(1)).thenAnswer((_) async => patient);
        await patientProvider.loadPatient(1);
        expect(patientProvider.selectedPatient, isNotNull);

        // Act
        patientProvider.clearSelection();

        // Assert
        expect(patientProvider.selectedPatient, isNull);
        expect(patientProvider.error, isNull);
      });
    });
  });
}
