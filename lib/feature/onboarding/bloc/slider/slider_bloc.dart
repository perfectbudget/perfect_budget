import 'package:bloc/bloc.dart';
import 'slider_event.dart';

class SliderBloc extends Bloc<SliderEvent, int> {
  SliderBloc() : super(0) {
    on<SwipeLeft>((event, emit) => emit(state - 1));
    on<SwipeRight>((event, emit) => emit(state + 1));
  }
}
