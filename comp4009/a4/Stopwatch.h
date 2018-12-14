class Stopwatch {
public:
    explicit Stopwatch();
    void Start();
    void Stop();
    double Elapsed() const;
private:
    double start, elapsed;
    bool running;
};