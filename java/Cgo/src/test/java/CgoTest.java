import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import static org.junit.Assert.*;

public class CgoTest {
    @Test
    public void add() {
        assertEquals(Cgo.add(1, 2), 3);
    }

    @Test
    public void addAndSubWithReturnResult() {
        Cgo.AddAndSubResult result1 = Cgo.addAndSub(2, 1);
        assertEquals(3, result1.add);
        assertEquals(1, result1.sub);
    }

    @Test
    public void addAndSubWithReturnArgument() {
        Cgo.AddAndSubResult result2 = new Cgo.AddAndSubResult();
        Cgo.addAndSub(4, 2, result2);
        assertEquals(6, result2.add);
        assertEquals(2, result2.sub);
    }

    @Test
    public void div() {
        assertEquals(2, Cgo.div(6, 3));
    }

    @Test
    public void divWithException() {
        try {
            assertEquals(0, Cgo.div(6, 0));
        } catch (ArithmeticException e) {
            return;
        }
        fail();
    }

    @Test
    public void divPtrs() {
        assertEquals(2, Cgo.divPtrs(6, 3));
    }

    @Test
    public void divPtrsWithException() {
        try {
            assertEquals(Cgo.divPtrs(6, 0), 0);
        } catch (ArithmeticException e) {
            return;
        }
        fail();
    }

    @Test
    public void sqrt() {
        assertEquals(2.0, Cgo.sqrt(4.0), 0.0);
    }

    @Test
    public void echo() {
        assertEquals("text", Cgo.echo("text"));
    }

    @Test
    public void echoFoo() {
        Cgo.Foo foo = new Cgo.Foo();
        foo.str = "text";
        foo.arr = new byte[]{1, 2, 3};
        foo.num = 10;

        Cgo.Foo result = null;
        try {
            result = Cgo.echoFoo(foo);
        } catch (Exception e) {
            e.printStackTrace();
        }
        assertEquals(foo.str, result.str);
        assertArrayEquals(foo.arr, result.arr);
        assertEquals(foo.num, result.num);
    }

    @Test
    public void streamInts() {
        List<Integer> buf = new ArrayList<Integer>();
        Cgo.streamInts(3, new Cgo.IntCallback() {
            @Override
            public void onValue(int value) {
                buf.add(value);
            }
        });
        assertEquals(Arrays.asList(0, 1, 2), buf);
    }

    @Test
    public void streamIntsAsync() {
        List<Integer> buf = new ArrayList<Integer>();

        Lock lock = new ReentrantLock();
        Condition done = lock.newCondition();
        lock.lock();

        Cgo.streamInts(3, new Cgo.IntStreamCallbacks() {
            @Override
            public void onValue(int value) {
                buf.add(value);
            }

            @Override
            public void onDone() {
                lock.lock();
                done.signal();
                lock.unlock();
            }
        });

        try {
            done.await();
        } catch (InterruptedException e) {
            fail();
        }

        assertEquals(Arrays.asList(0, 1, 2), buf);
    }

    @Test
    public void addAsync() {
        AtomicInteger result = new AtomicInteger();

        Lock lock = new ReentrantLock();
        Condition done = lock.newCondition();
        lock.lock();

        Cgo.addAsync(1, 2, new Cgo.IntCallback() {
            @Override
            public void onValue(int value) {
                result.set(value);
                lock.lock();
                done.signal();
                lock.unlock();
            }
        });

        try {
            done.await();
        } catch (InterruptedException e) {
            fail();
        }

        assertEquals(3, result.get());
    }
}
