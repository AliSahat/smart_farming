import 'package:sqflite/sqflite.dart';

abstract class BaseRepository<T> {
  Database get database;

  Future<int> insert(T entity);
  Future<List<T>> getAll();
  Future<T?> getById(int id);
  Future<int> update(T entity);
  Future<int> delete(int id);
}
