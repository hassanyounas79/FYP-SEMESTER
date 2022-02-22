class StudentMdl {
  late String name;
  late String key;
  late String pasword;
  int status = 0;
  StudentMdl({
    key,
    name,
  }) {
    pasword = key;
  }
}
