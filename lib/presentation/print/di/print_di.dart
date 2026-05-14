import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/print/print_card_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_di.g.dart';

@riverpod
PrintCardUseCase printCardUseCase(Ref ref) => PrintCardUseCase(ref);
