import 'package:mongo_dart/mongo_dart.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";

class MongoDbApiClient {
  static final mongoUri = dotenv.env['MONGODB_URI']!;
  static Future<List<Map<String, dynamic>>> getAllEntities(
      String collectionName) async {
    final db = await Db.create(mongoUri);
    await db.open();

    final entityCollection = db.collection(collectionName);

    final entities = await entityCollection.find().toList();

    await db.close();

    return entities.map((doc) => doc).toList();
  }

  static Future<Map<String, dynamic>> getEntityById(
      String collectionName, ObjectId id) async {
    final db = await Db.create(mongoUri);
    await db.open();

    final entityCollection = db.collection(collectionName);
    final entity = await entityCollection.findOne(where.eq('_id', id));

    await db.close();

    return entity as Map<String, dynamic>;
  }

  static Future<void> addEntity(
      String collectionName, Map<String, dynamic> document) async {
    final db = await Db.create(mongoUri);
    await db.open();

    final entityCollection = db.collection(collectionName);
    await entityCollection.insert(document);

    await db.close();
  }

  static Future<void> updateCounsellor(
      String id, Map<String, dynamic> updatedCounsellor) async {
    final db = await Db.create(mongoUri);
    await db.open();

    final entityCollection = db.collection('doctors_master');
    await entityCollection.update(
        where.eq('_id', ObjectId.fromHexString(id)), updatedCounsellor);

    await db.close();
  }

  static Future<void> deleteCounsellor(String id) async {
    final db = await Db.create(mongoUri);
    await db.open();

    final entityCollection = db.collection('doctors_master');
    await entityCollection.remove(where.eq('_id', ObjectId.fromHexString(id)));

    await db.close();
  }

  static Future<Map<String, dynamic>> getUserAppointments(String userId) async {
    final db = await Db.create(mongoUri);
    await db.open();

    final appointmentsCollection = db.collection('appointments_master');

    final completedAppointments = await appointmentsCollection
        .find(where.eq('user_id', userId).eq('status', 'Completed'))
        .toList();

    final upcomingAppointments = await appointmentsCollection
        .find(where.eq('user_id', userId).eq('status', 'Upcoming'))
        .toList();

    final cancelledAppointments = await appointmentsCollection
        .find(where.eq('user_id', userId).eq('status', 'Cancelled'))
        .toList();

    await db.close();

    final userAppointments = {
      "completed": completedAppointments,
      "upcoming": upcomingAppointments,
      "cancelled": cancelledAppointments
    };

    return userAppointments;
  }
}
